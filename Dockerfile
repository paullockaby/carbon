FROM python:3.9.4-slim-buster@sha256:bca2bcc8afda3abca3f73ff3d9ac146076aa47d09a226290eb3c99f175b1371a AS base

# github metadata
LABEL org.opencontainers.image.source https://github.com/paullockaby/carbon

FROM base AS builder

# packages needed for building this thing
RUN apt-get -q update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# install python dependencies
COPY requirements.txt /
RUN python3 -m venv --system-site-packages /opt/graphite && \
    . /opt/graphite/bin/activate && \
    pip3 install --no-cache-dir -r /requirements.txt

# install current version of carbon
ENV VERSION=1.1.8
RUN mkdir -p /usr/local/src && cd /usr/local/src && \
  curl -OJL https://github.com/graphite-project/whisper/archive/${VERSION}.tar.gz && \
  curl -OJL https://github.com/graphite-project/carbon/archive/${VERSION}.tar.gz && \
  tar zxf whisper-${VERSION}.tar.gz && \
  tar zxf carbon-${VERSION}.tar.gz && \
  . /opt/graphite/bin/activate && \
  cd /usr/local/src/whisper-$VERSION && python3 ./setup.py install && \
  cd /usr/local/src/carbon-$VERSION && python3 ./setup.py install && \
  true

FROM base AS final

# packages needed to run this thing
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -q update && \
    apt-get install -y --no-install-recommends tini && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# copy the virtual environment that we just built
COPY --from=builder /opt /opt

# install the entrypoint last to help with caching
COPY entrypoint /
RUN chmod +x /entrypoint

VOLUME ["/opt/graphite/conf", "/opt/graphite/storage"]
ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint"]
