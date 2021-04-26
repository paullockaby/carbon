FROM python:3.9.4-alpine@sha256:2a9b93b032246dabbec008c1527bd0ef31947e7fd351a200aec5a46eea68d776 AS base

# github metadata
LABEL org.opencontainers.image.source https://github.com/paullockaby/carbon

FROM base AS builder

# packages needed for building this thing
RUN apk add --no-cache curl

# install python dependencies
COPY requirements.txt /
RUN python3 -m venv /opt/graphite && \
    source /opt/graphite/bin/activate && \
    pip3 install --no-cache-dir -r /requirements.txt

# install current version of carbon
ENV VERSION=1.1.8
RUN mkdir -p /usr/local/src && cd /usr/local/src && \
  curl -OJL https://github.com/graphite-project/whisper/archive/${VERSION}.tar.gz && \
  curl -OJL https://github.com/graphite-project/carbon/archive/${VERSION}.tar.gz && \
  tar zxf whisper-${VERSION}.tar.gz && \
  tar zxf carbon-${VERSION}.tar.gz && \
  source /opt/graphite/bin/activate && \
  cd /usr/local/src/whisper-$VERSION && python3 ./setup.py install && \
  cd /usr/local/src/carbon-$VERSION && python3 ./setup.py install && \
  true

FROM base AS final

# packages needed to run this thing
RUN apk add --no-cache tini

# copy the virtual environment that we just built
COPY --from=builder /opt /opt

# install the entrypoint last to help with caching
COPY entrypoint /
RUN chmod +x /entrypoint

VOLUME ["/opt/graphite/conf", "/opt/graphite/storage"]
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint"]
