FROM build.synbioz.com/docker-images/rails/app:ruby3.2.2-rails7.0.5
LABEL maintainer="Infrastructure Plunge <jfrancois@plunge.cloud>"
ENV BUNDLE_WITHOUT=production \
    BUNDLE_WITH=development:test

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  wget \
  chromium \
  chromium-driver \
  libicu-dev \
  gsfonts \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

#cf https://imagetragick.com/
ADD ./ops/ci/release/base/image_magick_policy.xml /etc/ImageMagick-6/policy.xml

WORKDIR /app
COPY Gemfile* /app/
RUN bundle install

COPY package.json yarn.lock .yarnrc ./
ENV PATH /node_modules/.bin:$PATH
ENV NODE_PATH /node_modules/:$NODE_PATH
RUN yarn install
