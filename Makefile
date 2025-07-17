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
		--parameter-overrides AppName=$(APPNAME) Architecture=arm64 Stage=$(STAGE) UbuntuImageRecipeVersion=0.0.7

.PHONY: deploy-vpc
deploy-vpc:
	@echo "--- deploy stack $(APPNAME)-$(STAGE)-vpc"
	@aws cloudformation deploy \
			--no-fail-on-empty-changeset \
			--tags "environment=$(STAGE)" "service=$(APPNAME)" \
			--template-file vpc-3azs.yaml \
			--stack-name $(APPNAME)-$(STAGE)-vpc \
			--capabilities CAPABILITY_NAMED_IAM \
			--parameter-overrides ClassB=128

.PHONY: deploy-alert
deploy-alert:
	@echo "--- deploy stack $(APPNAME)-$(STAGE)-alert"
	@aws cloudformation deploy \
			--no-fail-on-empty-changeset \
			--tags "environment=$(STAGE)" "service=$(APPNAME)" \
			--template-file alert.yaml \
			--stack-name $(APPNAME)-$(STAGE)-alert \
			--capabilities CAPABILITY_NAMED_IAM \
			--parameter-overrides Email=$(ALERT_EMAIL)

.PHONY: deploy-ec2-asg
deploy-ec2-asg:
	@echo "--- deploy stack $(APPNAME)-$(STAGE)-ec2-asg"
	$(eval AMI := $(shell aws ssm get-parameter --name '/${STAGE}/images/${APPNAME}-ubuntu-arm64' --query 'Parameter.Value' --output text))
	@sam deploy \
			--no-fail-on-empty-changeset \
			--tags "environment=$(STAGE)" "service=$(APPNAME)" \
			--template-file ec2-asg.yaml \
			--stack-name $(APPNAME)-$(STAGE)-ec2-asg \
			--capabilities CAPABILITY_NAMED_IAM \
			--parameter-overrides \
					AppName=$(APPNAME) \
					Stage=$(STAGE) \
					ParentVPCStack=$(APPNAME)-$(STAGE)-vpc \
					ParentAlertStack=$(APPNAME)-$(STAGE)-alert \
					DesiredCapacity=1 \
					BuildkiteAgentToken=$(BUILDKITE_AGENT_TOKEN) \
					AMI=$(AMI) \
					InstanceType=t4g.large

import-ssm-env:
	aws ssm put-parameter --name "/${STAGE}/buildkite-agent/env/BUILDKITE_TRACING_BACKEND" --type String --value "${BUILDKITE_TRACING_BACKEND}"
	aws ssm put-parameter --name "/${STAGE}/buildkite-agent/env/OTEL_SERVICE_NAME" --type String --value "${OTEL_SERVICE_NAME}"
	aws ssm put-parameter --name "/${STAGE}/buildkite-agent/env/OTEL_EXPORTER_OTLP_PROTOCOL" --type String --value "${OTEL_EXPORTER_OTLP_PROTOCOL}"
	aws ssm put-parameter --name "/${STAGE}/buildkite-agent/env/OTEL_EXPORTER_OTLP_ENDPOINT" --type String --value "${OTEL_EXPORTER_OTLP_ENDPOINT}"
	aws ssm put-parameter --name "/${STAGE}/buildkite-agent/env/OTEL_EXPORTER_OTLP_HEADERS" --type SecureString --value "${OTEL_EXPORTER_OTLP_HEADERS}"
