ARG BASE_IMAGE_TAG=latest
FROM build.synbioz.com/addullact/demarches-simplifiees.fr/base:${BASE_IMAGE_TAG}
LABEL maintainer="Infrastructure Plunge <jfrancois@plunge.cloud>"

WORKDIR /app

COPY Gemfile* /app/
RUN bundle install

COPY package.json yarn.lock .yarnrc ./
ENV PATH /node_modules/.bin:$PATH
ENV NODE_PATH /node_modules/:$NODE_PATH
RUN yarn install

ADD . /app/

CMD rm -f /app/tmp/pids/server.pid && rails s -b 0.0.0.0
