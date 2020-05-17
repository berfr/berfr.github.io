.PHONY: setup build publish

setup:
	rm -rf public
	git clone git@github.com:berfr/berfr.github.io.git public

build:
	rm -rf public/*
	hugo --minify

publish: setup build
	git -C public add --all
	git -C public commit -m "Publishing to gh-pages: $(shell date +%y-%m-%d\ %H:%M)"
	git -C public push origin master
