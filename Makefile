APPNAME := buildkite-agent
STAGE ?= dev

.PHONY: image-builder-ubuntu-2204-arm64
image-builder-ubuntu-2204-arm64:
	@echo "--- deploy stack $(APPNAME)-arm64-$(STAGE)"
	@sam deploy \
		--no-fail-on-empty-changeset \
		--template-file agent-image-builder.cfn.yml \
		--capabilities CAPABILITY_IAM \
		--tags "environment=$(STAGE)" "application=$(APPNAME)" \
		--stack-name $(APPNAME)-ubuntu-image-builder-arm64-$(STAGE) \
		--parameter-overrides AppName=$(APPNAME) Architecture=arm64 Stage=$(STAGE)
