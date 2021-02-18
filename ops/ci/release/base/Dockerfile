FROM build.synbioz.com/docker-images/rails/app:ruby3.0.3-rails6.1.4.1
LABEL maintainer="Infrastructure Plunge <jfrancois@plunge.cloud>"

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  libgeos-dev \
  libicu-dev \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

WORKDIR /app
COPY Gemfile* /app/
RUN bundle install

COPY package.json yarn.lock .yarnrc ./
ENV PATH /node_modules/.bin:$PATH
ENV NODE_PATH /node_modules/:$NODE_PATH
RUN yarn install

CMD rm -f /app/tmp/pids/server.pid && rails s -b 0.0.0.0
