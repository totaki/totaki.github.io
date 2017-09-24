FROM ruby:2.2
RUN gem install bundler
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get -y install nodejs
RUN mkdir /app
RUN mkdir /app/src
WORKDIR /app
COPY Gemfile /app/Gemfile
RUN bundle install
WORKDIR /app/src

