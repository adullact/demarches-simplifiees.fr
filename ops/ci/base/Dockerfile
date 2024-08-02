ARG RAILS_VERSION

FROM build.ouidou.fr/docker-images/ruby_jemalloc/app:3.3.1

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

# Copy your packages list file into the image
ARG PACKAGE
COPY ${PACKAGE} /app/packages.txt

# We use an external file to handle dependencies as a way to invalidate our cache and trigger a fresh base build.
RUN apt-get update && \
    xargs -a /app/packages.txt apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

#cf https://imagetragick.com/
ADD ./ops/ci/base/image_magick_policy.xml /etc/ImageMagick-6/policy.xml

WORKDIR /app

COPY Gemfile* .ruby-version /app/

RUN bundle install

COPY package.json bun.lockb ./
ENV PATH /app/node_modules/.bin:$PATH
ENV NODE_PATH /app/node_modules/:$NODE_PATH
ENV VITE_RUBY_VITE_BIN_PATH /app/node_modules/.bin/vite
RUN bun install

CMD rm -f /app/tmp/pids/server.pid && rails s -b 0.0.0.0
