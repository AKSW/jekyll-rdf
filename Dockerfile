FROM ruby:3.1-slim AS builder

RUN apt-get update && apt-get -y install build-essential && rm -rf /var/lib/apt/lists/*
WORKDIR jekyll-rdf

ADD . .
ARG VERSION
RUN gem build jekyll-rdf.gemspec && \
    gem install jekyll-rdf-*.gem mustache

FROM ruby:3.1-slim AS slim
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

WORKDIR /data

CMD /usr/local/bundle/bin/jekyll build

FROM ruby:3.1-slim
COPY --from=builder /jekyll-rdf/docker-resources/ /docker-resources
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
RUN apt-get update && apt-get -y install build-essential git && rm -rf /var/lib/apt/lists/*

WORKDIR /data

ENTRYPOINT ["/docker-resources/entrypoint.sh"]
