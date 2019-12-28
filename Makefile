.PHONY: build deploy

build:
	hugo --cleanDestinationDir --minify

deploy: build
	./deploy.sh
