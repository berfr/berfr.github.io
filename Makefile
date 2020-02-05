.PHONY: build deploy release

build:
	hugo --cleanDestinationDir --minify

deploy: build
	aws --region ca-central-1 --profile s3-berfr.me s3 sync public/ s3://berfr.me/

release: build
	git tag -s -a "`date +\"%y-%m-%d-%H-%M\"`" -m "`date`"
