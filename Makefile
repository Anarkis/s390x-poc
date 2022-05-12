# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Add the following 'help' target to your Makefile
# And add help text after each target name starting with '\#\#'

.DEFAULT_GOAL:=help

.EXPORT_ALL_VARIABLES:

ifndef VERBOSE
.SILENT:
endif

# set default shell
SHELL=/bin/bash -o pipefail -o errexit

# Use the 0.0 tag for testing, it shouldn't clobber any release builds
TAG ?= $(shell cat TAG)

# e2e settings
# Allow limiting the scope of the e2e tests. By default run everything
FOCUS ?= .*
# number of parallel test
E2E_NODES ?= 7
# run e2e test suite with tests that check for memory leaks? (default is false)
E2E_CHECK_LEAKS ?=

REPO_INFO ?= $(shell git config --get remote.origin.url)
COMMIT_SHA ?= git-$(shell git rev-parse --short HEAD)
BUILD_ID ?= "UNSET"

PKG = k8s.io/ingress-nginx

HOST_ARCH = $(shell which go >/dev/null 2>&1 && go env GOARCH)
ARCH ?= $(HOST_ARCH)
ifeq ($(ARCH),)
    $(error mandatory variable ARCH is empty, either set it when calling the command or make sure 'go env GOARCH' works)
endif

ifneq ($(PLATFORM),)
	PLATFORM_FLAG="--platform"
endif

REGISTRY ?= gcr.io/k8s-staging-ingress-nginx

BASE_IMAGE ?= rancher/nginx:ingress-v1.2.0-hardened

GOARCH=$(ARCH)

.PHONY: build
build:  ## Build ingress controller, debug tool and pre-stop hook.
	@run-in-docker.sh \
		PKG=$(PKG) \
		ARCH=$(ARCH) \
		COMMIT_SHA=$(COMMIT_SHA) \
		REPO_INFO=$(REPO_INFO) \
		TAG=$(TAG) \
		GOBUILD_FLAGS=$(GOBUILD_FLAGS) \
		build.sh
