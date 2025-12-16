FROM ruby:3.2.4

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  npm \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Pin RubyGems
RUN gem update --system 3.3.26

# Pin Bundler to EXACT lockfile version
RUN gem install bundler -v 2.6.2

COPY Gemfile Gemfile.lock ./

# Force correct bundler version
RUN bundle _2.6.2_ install

COPY . .

EXPOSE 3000
CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails s -b 0.0.0.0"]
