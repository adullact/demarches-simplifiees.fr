ARG BASE_IMAGE_TAG=develop-latest
FROM build.synbioz.com/addullact/demarches-simplifiees.fr/base:${BASE_IMAGE_TAG}
LABEL maintainer="Infrastructure Plunge <jfrancois@plunge.cloud>"
ENV BUNDLE_WITHOUT=production \
    BUNDLE_WITH=development:test

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  wget \
  chromium \
  chromium-driver \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

WORKDIR /app
COPY Gemfile* /app/
RUN bundle install

COPY package.json yarn.lock .yarnrc ./
ENV PATH /node_modules/.bin:$PATH
ENV NODE_PATH /node_modules/:$NODE_PATH
RUN yarn install
