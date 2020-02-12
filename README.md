[![CircleCI](https://circleci.com/gh/ministryofjustice/fb-user-datastore/tree/master.svg?style=svg)](https://circleci.com/gh/ministryofjustice/fb-user-datastore/tree/master)

# fb-user-datastore

User Data store API for services built and deployed on Form Builder

## Running tests

Prerequisites:

- Docker

Clone repository

```sh
git clone git@github.com:ministryofjustice/fb-user-datastore.git && cd fb-user-datastore.git
```

Run the tests through docker and docker-compose

```sh
make spec
```

## Deployment

Continuous Integration (CI) is enabled on this project via CircleCI.

On merge to master tests are executed and if green deployed to the test environment. This build can then be promoted to production
