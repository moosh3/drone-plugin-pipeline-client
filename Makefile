EXECUTABLE ?= pipeline-client
IMAGE ?= banzaicloud/$(EXECUTABLE)
TAG ?= dev-$(shell git log -1 --pretty=format:"%h")

PACKAGES = $(shell go list ./... | grep -v /vendor/)

.DEFAULT_GOAL := list

.PHONY: list
list:
	@$(MAKE) -pRrn : -f $(MAKEFILE_LIST) 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | sort

all: clean deps fmt vet build

clean:
	rm -rf bin/*
	go clean -i ./...

deps:
	go get ./...

fmt:
	go fmt $(PACKAGES)

vet:
	go vet $(PACKAGES)

docker:
	docker build --rm -t $(IMAGE):$(TAG) .

push:
	docker push $(IMAGE):$(TAG)

$(EXECUTABLE): $(wildcard *.go)
	go build -o bin/$(EXECUTABLE)

build: $(EXECUTABLE)
