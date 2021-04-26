FROM python:3.9.4-alpine@sha256:2a9b93b032246dabbec008c1527bd0ef31947e7fd351a200aec5a46eea68d776

# github metadata
LABEL org.opencontainers.image.source https://github.com/paullockaby/carbon

# need curl to download packages for build
RUN apk add --no-cache tini curl

# install python dependencies
COPY requirements.txt /
RUN pip3 install --no-cache-dir -r /requirements.txt \
    && rm -rf /requirements.txt ~/.cache

# install current version of carbon
ENV VERSION=1.1.8
RUN mkdir -p /usr/local/src && cd /usr/local/src && \
  curl -OJL https://github.com/graphite-project/whisper/archive/${VERSION}.tar.gz && \
  curl -OJL https://github.com/graphite-project/carbon/archive/${VERSION}.tar.gz && \
  tar zxf whisper-${VERSION}.tar.gz && \
  tar zxf carbon-${VERSION}.tar.gz && \
  cd /usr/local/src/whisper-$VERSION && python3 ./setup.py install && \
  cd /usr/local/src/carbon-$VERSION && python3 ./setup.py install && \
  rm -rf /usr/local/src ~/.cache

# install the entrypoint last to help with caching
COPY entrypoint /
RUN chmod +x /entrypoint

VOLUME ["/opt/graphite/conf", "/opt/graphite/storage"]
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint"]
