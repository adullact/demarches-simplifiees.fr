FROM build.ouidou.fr/docker-images/ruby_jemalloc/app:3.3.1
LABEL maintainer="Infrastructure Plunge <jfrancois@plunge.cloud>"
ENV BUNDLE_WITHOUT=production \
    BUNDLE_WITH=development:test

ENV PATH /root/.bun/bin:$PATH

ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
  BUNDLE_BIN="$GEM_HOME/bin" \
  BUNDLE_SILENCE_ROOT_WARNING=1 \
  BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $BUNDLE_BIN:$PATH

RUN apt-get update -q \
    && apt-get install -qqy apt-transport-https \
    build-essential \
    patch \
    ruby-dev \
    zlib1g-dev \
    liblzma-dev \
    gnupg \
    postgresql-client \
    && curl -sL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -qqy nodejs \
    && curl -fsSL https://bun.sh/install | bash \
    && apt-get autoremove --assume-yes \
    && rm -rf /tmp/* /var/tmp/*

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
ADD ./ops/ci/base/image_magick_policy.xml /etc/ImageMagick-6/policy.xml

WORKDIR /app
COPY Gemfile* /app/
RUN bundle install

COPY package.json bun.lockb ./
ENV PATH /app/node_modules/.bin:$PATH
ENV NODE_PATH /app/node_modules/:$NODE_PATH
RUN bun install
