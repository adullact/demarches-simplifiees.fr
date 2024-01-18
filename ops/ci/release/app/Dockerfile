ARG CI_REGISTRY_IMAGE
ARG CI_COMMIT_REF_SLUG
ARG CI_COMMIT_TAG
FROM ${CI_REGISTRY_IMAGE}/base:${CI_COMMIT_TAG:-$CI_COMMIT_REF_SLUG}

WORKDIR /app

COPY Gemfile* .ruby-version /app/

RUN bundle install

COPY package.json yarn.lock .yarnrc ./
ENV PATH /app/node_modules/.bin:$PATH
ENV NODE_PATH /app/node_modules/:$NODE_PATH
RUN yarn install

ADD . /app/

CMD rm -f /app/tmp/pids/server.pid && rails s -b 0.0.0.0
