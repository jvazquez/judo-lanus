DOCKER = $(if $(DOCKER_BINARY),$(DOCKER_BINARY),/usr/bin/docker)
BUILD_ARG = $(if $(filter $(NOCACHE), 1),--no-cache)
GENERATE_USER_ID = $(shell id -u)
USER_ID = $(if $(USERID),$(USERID),1000)
GROUP_ID = 101
DEVELOPMENT_ENVIRONMENT=develop
TEST_ENVIRONMENT=test
NETWORKNAME=judo-lanus

local_stop: local_shutdown
local_all: host_dependencies local_judo-lanus_api

# Below this line, you don't use any of this rules as a developer
test_stop: test_shutdown
test_up: test_start
test_judo-lanus_api_build: judo-lanus_api_code_image test_judo-lanus_api test_nginx_api

host_dependencies:
	$(DOCKER) volume create --name=judo-lanus-api
	$(DOCKER) network ls || grep $(NETWORKNAME) > /dev/null || $(DOCKER) network create $(NETWORKNAME)
local_start:
	docker-compose up -d

local_judo-lanus_api:
	$(SET_ID)
	$(DOCKER) build $(BUILD_ARG) -f images/develop/api/Dockerfile \
	--build-arg BUILD_PROFILE=$(DEVELOPMENT_ENVIRONMENT) \
	--build-arg USER_ID=$(USER_ID) \
	--build-arg GROUP_ID=$(GROUP_ID) \
	-t judo-lanus-$(DEVELOPMENT_ENVIRONMENT) .

local_shutdown:
	docker-compose --compatibility stop
	docker-compose --compatibility down --volumes

# Test profile
test_start:
	docker-compose -f docker-compose.test.ecs.yml --compatibility up -d
test_shutdown:
	docker-compose -f docker-compose.test.ecs.yml --compatibility stop
	docker-compose -f docker-compose.test.ecs.yml --compatibility down --volumes --remove-orphans

judo-lanus_api_code_image:
	# Clean old socket file
	find . -iname *.sock -delete
	$(DOCKER) volume rm -f judo-lanus-api-django-volume
	$(DOCKER) volume create judo-lanus-api-django-volume
	$(DOCKER) stop judo-lanus-api-container || true && docker rm judo-lanus-api-container || true
	$(DOCKER) run -v judo-lanus-api-django-volume:/services --name judo-lanus-api-container busybox true
	$(DOCKER) cp ./judo-lanus judo-lanus-api-container:/services
	$(DOCKER) cp ./dependencies judo-lanus-api-container:/services/dependencies
	$(DOCKER) cp ./supervisor-conf judo-lanus-api-container:/services/supervisor-conf
	$(DOCKER) cp ./assets/test/vassal judo-lanus-api-container:/services/vassal
	$(DOCKER) stop judo-lanus-api-container
	$(DOCKER) rm judo-lanus-api-container

test_judo-lanus_api:
	$(DOCKER) build $(BUILD_ARG) -f images/test/api/Dockerfile \
	--build-arg BUILD_PROFILE=$(TEST_ENVIRONMENT) \
	--build-arg IMAGE_NAME=$(PYTHON) \
	--build-arg USER_ID=$(USER_ID) \
	--build-arg GROUP_ID=$(GROUP_ID) \
	-t judo-lanus-api-$(TEST_ENVIRONMENT) .
test_nginx_api:
	$(DOCKER) build $(BUILD_ARG) \
	--build-arg USER_ID=$(USER_ID) \
	--build-arg GROUP_ID=$(GROUP_ID) \
	-f images/test/api-nginx/Dockerfile \
	-t nginx-api-$(TEST_ENVIRONMENT) .
