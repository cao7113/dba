FROM ruby:2.5-alpine3.7
# apk add postgresql=9.6.3
# RUN apk add --no-cache postgresql-client
RUN apk add postgresql-dev build-base
WORKDIR /app
COPY Gemfile ./
ENV GEM_SOURCE=http://docker.for.mac.host.internal:8808
RUN bundle install --without development test --verbose
COPY . /app
ENV PATH=/app/bin:$PATH
CMD bash
