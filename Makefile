.PHONY: build deploy

build:
	hugo --cleanDestinationDir

deploy: build
	./deploy.sh
