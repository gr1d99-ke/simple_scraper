FROM ruby:2.6.3-slim

RUN mkdir /my-app
WORKDIR /my-app

RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev curl cmake git apt-utils

# Node
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash - && \
  apt-get install -y nodejs

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY Gemfile Gemfile.lock ./

RUN gem install bundler -v 2.1.4
RUN bundle check || bundle install

COPY . ./

RUN pwd

EXPOSE 3000

ENTRYPOINT ["./docker-entrypoint.sh"]
