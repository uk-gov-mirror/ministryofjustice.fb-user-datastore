# fb-user-datastore
[![CircleCI](https://circleci.com/gh/ministryofjustice/fb-user-datastore/tree/master.svg?style=svg)](https://circleci.com/gh/ministryofjustice/fb-user-datastore/tree/master)
[![Build Status](https://travis-ci.org/ministryofjustice/fb-user-datastore.svg?branch=master)](https://travis-ci.org/ministryofjustice/fb-user-datastore)

User Data store API for services built and deployed on Form Builder

## Setting up development environment

Prerequisites:

- Ruby and Bundler
- Node.js and NPM
- PostgreSQL
- Docker - to build images to deploy

Clone repository
```sh
git clone git@github.com:ministryofjustice/fb-user-datastore.git && cd fb-user-datastore.git
```

Intall gems
```sh
bundle install
```

Setup database
```sh
bundle exec rake db:create db:migrate
```

### Running tests

```sh
bundle exec rspec
```

Or via Guard to run tests continuously
```sh
bundle exec guard
```

### Swagger docs

```sh
bundle exec rails s
open http://localhost:3000/api-docs
```

They are also available at on the [GitHub Page](https://ministryofjustice.github.io/fb-user-datastore), however you will not be able to make API requests.

## Environment Variables

The following environment variables are either needed, or read if present:

* `DATABASE_URL`: used to connect to the database
* `RAILS_ENV`: 'development' or 'production'
* `REDIS_URL` or `REDISCLOUD_URL`: if either of these are present, cache tokens in
  Redis at this URL rather than in local files (default)
* `FB_ENVIRONMENT_SLUG`: 'dev', 'staging', or 'production' - which Form Builder
  environment is this running in? This will affect the suffix of the K8s
  secrets & namespaces it will try to read service tokens from
* `KUBECTL_BEARER_TOKEN`: identifies the ServiceAccount the app will authenticate
  against in kubernetes for kubectl calls
* `KUBECTL_CONTEXT`: (optional) which kubectl context it will look for secrets in
* `SERVICE_TOKEN_CACHE_TTL`: expire service token cache entries after this many
  seconds
* `FORM_URL_SUFFIX`: URL suffix to the form. The prefix part if the form slug.
  This is what is sent to the user in emails.

## To deploy and run on Cloud Platforms

See [deployment instructions](DEPLOY.md)
