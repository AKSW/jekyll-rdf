FROM ruby:3-slim AS builder

RUN apt-get update && apt-get -y install build-essential libyaml-dev && rm -rf /var/lib/apt/lists/*
WORKDIR jekyll-rdf

ADD . .
RUN gem build jekyll-rdf.gemspec && \
    gem install jekyll-rdf-*.gem mustache

FROM ruby:3-slim
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
RUN apt-get update && apt-get -y install jq && rm -rf /var/lib/apt/lists/*

WORKDIR /data

CMD /usr/bin/jekyll
