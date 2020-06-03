.PHONY: setup build publish

setup:
	rm -rf public
	git clone --branch master git@github.com:berfr/berfr.github.io.git public

build:
	rm -rf public/*
	hugo --minify

publish:
	git -C public config user.email "berfr4@gmail.com"
	git -C public config user.name "berfr"
	git -C public add --all
	git -C public commit -m "Publishing to gh-pages: $(shell date +%y-%m-%d\ %H:%M)" || true
	git -C public push origin master
