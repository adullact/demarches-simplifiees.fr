ARG RAILS_VERSION

FROM build.ouidou.fr/docker-images/rails/app:${RAILS_VERSION}

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

COPY package.json yarn.lock .yarnrc ./
ENV PATH /app/node_modules/.bin:$PATH
ENV NODE_PATH /app/node_modules/:$NODE_PATH
ENV VITE_RUBY_VITE_BIN_PATH /app/node_modules/.bin/vite
RUN yarn install

CMD rm -f /app/tmp/pids/server.pid && rails s -b 0.0.0.0
