# Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
# 	http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

VERSION := $(shell git describe --tags --candidates=1 --dirty 2>/dev/null || echo "dev")
FLAGS := -s -w -X main.Version=$(VERSION)
ROOT := $(shell pwd)
PKG := ./cli/docker-credential-ecr-login

all: build

SOURCEDIR=./ecr-login
SOURCES := $(shell find . -name '*.go')
LOCAL_BINARY=bin/local/docker-credential-ecr-login

.PHONY: docker
docker: Dockerfile
	docker run --rm \
	-e TARGET_GOOS=$(TARGET_GOOS) \
	-e TARGET_GOARCH=$(TARGET_GOARCH) \
	-v $(shell pwd)/bin:/go/src/github.com/awslabs/amazon-ecr-credential-helper/bin \
	$(shell docker build -q .)

.PHONY: build
build: $(LOCAL_BINARY)

$(LOCAL_BINARY): $(SOURCES)
	go install -a -ldflags="$(FLAGS)" $(PKG)
	go build -v -ldflags="$(FLAGS)" -o $(LOCAL_BINARY) $(PKG)

.PHONY: test
test:
	govendor test -v -timeout 30s -short -cover +l

.PHONY: get-deps
get-deps:
	go get github.com/kardianos/govendor

.PHONY: clean
clean:
	rm -rf ./bin ||:

.PHONY: release
release:
	go get github.com/mitchellh/gox
	gox -ldflags="$(FLAGS)" -output="bin/local/{{.Dir}}_{{.OS}}_{{.Arch}}" -osarch="linux/amd64 darwin/amd64 windows/amd64" $(PKG)  
