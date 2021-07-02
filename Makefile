#vars
USER_NAME=vasiilij
BUILD_SCRIPT=docker_build.sh

.PHONY: build push all

.DEFAULT_GOAL := all

build: build_prometheus build_comment build_post build_ui

push: push_prometheus push_comment push_post push_ui

all: build push

build_prometheus:
	cd monitoring/prometheus && bash $(BUILD_SCRIPT)
build_comment:
	cd src/comment && bash $(BUILD_SCRIPT)
build_post:
	cd src/post-py && bash $(BUILD_SCRIPT)
build_ui:
	cd src/ui && bash $(BUILD_SCRIPT)

push_prometheus:
	docker push $(USER_NAME)/prometheus
push_comment:
	docker push $(USER_NAME)/comment
push_post push_ui:
	docker push $(USER_NAME)/post
