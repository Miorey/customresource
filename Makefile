
TIMESTAMP:=$(shell date +%s)
CURRENT_DIR:=$(shell pwd)

predeploy:
	# Create local and remote directories / bucket
	mkdir -p dist

	# Deploy bucket cloudformation
	aws cloudformation deploy \
	--template-file ./infra/bucket.json \
	--stack-name "bucketDeployment" \
	--region eu-west-3 \
	--no-fail-on-empty-changeset

deploy: predeploy

	# Cloudformation custom resources
	cd ${CURRENT_DIR}/lambda/custom_resources;	 \
	zip -r $(CURRENT_DIR)/dist/$(TIMESTAMP)_custom_resources.zip *

	aws s3 cp ./dist/$(TIMESTAMP)_custom_resources.zip s3://custom-resources-deployment/

	# Deploy cloudformation
	aws cloudformation deploy \
	--template-file ./infra/custom_resources.json \
	--stack-name "customResources" \
	--parameter-overrides Timestamp="$(TIMESTAMP)" \
	--s3-bucket custom-resources-deployment \
	--region eu-west-3 \
	--capabilities CAPABILITY_NAMED_IAM \
	--no-fail-on-empty-changeset


example: predeploy
	# Require make deploy

	# Cloudformation example resources
	cd ${CURRENT_DIR}/lambda/example;	 \
	zip -r $(CURRENT_DIR)/dist/$(TIMESTAMP)my_example.zip *

	aws s3 cp ./dist/$(TIMESTAMP)my_example.zip s3://custom-resources-deployment/

	# Deploy cloudformation
	aws cloudformation deploy \
	--template-file ./infra/example.json \
	--stack-name "myExample" \
	--parameter-overrides Timestamp="$(TIMESTAMP)" \
	--s3-bucket custom-resources-deployment \
	--region eu-west-3 \
	--capabilities CAPABILITY_NAMED_IAM \
	--no-fail-on-empty-changeset


all: deploy example
