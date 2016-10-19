FROM ruby:2.3

MAINTAINER "Helen Zhang" <helenfanzhang@gmail.com>

RUN apt-get update
RUN gem install bundler
RUN mkdir test_app
WORKDIR /test_app

ADD . /test_app

RUN bundle install --without development test \
    && apt-get install -y nodejs

EXPOSE 3000

CMD ["rails", "server", "-e", "production", "-b", "0.0.0.0"]