FROM build.ouidou.fr/docker-images/rails/app:ruby3.3.0-rails7.0.8
LABEL maintainer="Infrastructure Plunge <jfrancois@plunge.cloud>"

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  libgeos-dev \
  libicu-dev \
  gsfonts \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

#cf https://imagetragick.com/
ADD ./ops/ci/base/image_magick_policy.xml /etc/ImageMagick-6/policy.xml

WORKDIR /app
COPY Gemfile* /app/
RUN bundle install

COPY package.json yarn.lock .yarnrc ./
ENV PATH /app/node_modules/.bin:$PATH
ENV NODE_PATH /app/node_modules/:$NODE_PATH
RUN yarn install

CMD rm -f /app/tmp/pids/server.pid && rails s -b 0.0.0.0
