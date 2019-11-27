DOCKER_COMPOSE = docker-compose -f docker-compose.yml

dev:
	echo "TODO: Remove dev function call from deploy-utils"

test:
	echo "TODO: Remove test function call from deploy-utils"

integration:
	echo "TODO: Remove integration function call from deploy-utils"

live:
	echo "TODO: Remove live function call from deploy-utils"

init:
	$(eval export ECR_REPO_URL=754256621582.dkr.ecr.eu-west-2.amazonaws.com/formbuilder/fb-user-datastore-api)

install_build_dependencies:
	docker --version
	pip install --user awscli
	$(eval export PATH=${PATH}:${HOME}/.local/bin/)

login: init
	@eval $(shell aws ecr get-login --no-include-email --region eu-west-2)

build: stop
	$(DOCKER_COMPOSE) build --build-arg BUNDLE_FLAGS=''

serve: build
	$(DOCKER_COMPOSE) up -d db
	./scripts/wait_for_db.sh db postgres
	$(DOCKER_COMPOSE) up -d app

stop:
	$(DOCKER_COMPOSE) down -v

spec: build
	$(DOCKER_COMPOSE) up -d db
	./scripts/wait_for_db.sh db postgres
	$(DOCKER_COMPOSE) run -e RAILS_ENV=test --rm app bundle exec rspec ${ARGS}

build_and_push: install_build_dependencies login
	docker build -t ${ECR_REPO_URL}:latest --build-arg BUNDLE_FLAGS="--without test development" -t ${ECR_REPO_URL}:${CIRCLE_SHA1} -f ./Dockerfile .
	docker push ${ECR_REPO_URL}:latest
	docker push ${ECR_REPO_URL}:${CIRCLE_SHA1} #multiple tags in ECR can only be done by pushing twice

.PHONY := init build login test stop serve
