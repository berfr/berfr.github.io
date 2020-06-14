---
title: Blogging under GitHub Pages
date: 2020-06-14
---

I recently moved my blog from [Amazon S3] using a custom domain to [GitHub
Pages] using the default `<username>.github.io` domain. Here, I'll discuss a few
thoughts on this.

[Amazon S3]: https://aws.amazon.com/s3
[GitHub Pages]: https://pages.github.com

## What happens when I die

One of the reasons I chose to host this blog under GitHub Pages has to do with
my eventual death. I like the idea of the articles written here living on after
I am gone and this is more likely using a free hosting service. With an S3
bucket and a registered domain, your work disappears from the internet when the
credit card expires and the account is due. It is true that no one knows for
certain where GitHub or their Pages product will be in a few years but it is
hard to imagine them purging the content of millions of people in the coming
years. Not much has changed on the user side of GitHub Pages since its
introduction in 2008 and I would be perfectly happy if my site outlived me by a
decade.

## Hugo and GitHub Actions

As for the technical side of this blog, I set up a simple [GitHub Actions]
workflow to build the website using [Hugo] and deploy the result. There are
multiple projects available on the Actions Marketplace but they are not
necessary. Doing it yourself requires only a few easy steps.

First, you need to add a Deploy Key and Secret to your `<username>.github.io`
repository. These will be the public and private keys of a newly generated SSH
key. With this in place, the machine that builds the website in CI will be able
to push to the `master` branch of the project where the resulting website needs
to be. Note that the main branch of your repository cannot be `master`.

After setting up the repo keys, you can add the following files to your project
and adapt them to your specific needs:

[`Makefile@eb87588`](https://github.com/berfr/berfr.github.io/blob/eb875880acba00ec8c71d2da5bb9ff3386edd2cf/Makefile):

```makefile
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
```

[`.github/workflows/workflow.yml@eb87588`](https://github.com/berfr/berfr.github.io/blob/eb875880acba00ec8c71d2da5bb9ff3386edd2cf/.github/workflows/workflow.yml):

```yaml
name: Main workflow
on: push

jobs:
  build:
    name: Build and Publish
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Install Hugo
        run: sudo snap install hugo --channel=extended
      - name: Set up SSH key
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
        run: |
          mkdir ~/.ssh
          echo "$DEPLOY_KEY" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
      - name: Set up public directory
        run: make setup
      - name: Build website
        run: GIT_CONFIG_NOSYSTEM=true make build
      - name: Publish website
        run: make publish
```

[GitHub Actions]: https://github.com/features/actions
[Hugo]: https://gohugo.io

With this in place, every push to the repository will trigger a website build
and the results will be published automatically.

## Other thoughts

Although this setup is good for now and probably for the next few years, it is
not ideal. It would be really nice for the platform itself to be open source
which I can see happening eventually. A guarantee of some sort would also ease
my mind. It is important to know that I am currently not in control of the
availability of my blog; if GitHub/Microsoft does not like it, they can simply
take it down. Even if I am not really worried about that, it is still a
possibility. There will certainly be a better hosting method in the future but
until then, this one isn't so bad.
