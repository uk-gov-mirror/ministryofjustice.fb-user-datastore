[![CircleCI](https://circleci.com/gh/ministryofjustice/fb-user-datastore/tree/master.svg?style=svg)](https://circleci.com/gh/ministryofjustice/fb-user-datastore/tree/master)

# fb-user-datastore

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

## Deployment

Continuous Integration (CI) is enabled on this project via CircleCI.

On merge to master tests are executed and if green deployed to the test environment. This build can then be promoted to production
