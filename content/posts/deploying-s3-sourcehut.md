---
title: Deploying to S3 with Sourcehut
date: 2020-02-05
---

In this article, we will go through the process of automatically building and
deploying this [Hugo] website to [Amazon S3] using [Sourcehut][Sourcehut]
[builds.sr.ht]. This post assumes you already have a static website that is
hosted on S3; there are plenty of guides online concerning this if it is not the
case.

[Hugo]: https://gohugo.io
[Amazon S3]: https://aws.amazon.com/s3
[Sourcehut]: https://sourcehut.org
[builds.sr.ht]: https://builds.sr.ht

##  IAM policy for S3 bucket access

The first step is to create an [IAM user] with an [IAM policy] that can only
modify the contents of the specific S3 bucket. This will ensure that if the user
credentials are compromised, only the specific bucket is affected and not your
complete AWS account. This is important since this user secret key will be saved
on Sourcehut which is not immune to security bugs and breaches.

Once the new user is created, note its Access Key ID and Secret Access Key. We
will be using these to access AWS from the CI environment.

We will be using the [`s3 sync`] command from the [AWS CLI] tool which requires
specific permissions to work. To get it to execute without errors, the following
policy is attached directly to the IAM user:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::berfr.me",
                "arn:aws:s3:::berfr.me/*"
            ]
        }
    ]
}
```

[IAM user]: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users.html
[IAM policy]: https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html
[`s3 sync`]: https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html
[AWS CLI]: https://aws.amazon.com/cli/

## Sourcehut secrets

We will now copy the IAM user credentials noted earlier into Sourcehut [build
secrets] so it is available during CI builds. Create a new secret of `File` type
at `~/.aws/credentials` with the content in this format:

```
[s3-berfr.me]
aws_access_key_id=AKIAIOSFODNN7EXAMPLE
aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

You can give the file minimum read permissions `400`. Save the secret and note
the resulting UUID; we will use it in the build manifest file.

[build secrets]: https://man.sr.ht/builds.sr.ht/#secrets

## Sourcehut build manifest

The next step will be to create a build [manifest]: the `.build.yml` file in the
root of the repository with the information and instructions to build and deploy
the static website. Here are the contents for this specific site:

```YAML
image: fedora/31
packages:
    - awscli
    - hugo
sources:
    - https://git.sr.ht/~berfr/berfr.me
secrets:
    - 1af67a38-6cf0-4f09-98fc-8776b8987160
tasks:
    - build: |
        cd berfr.me
        make build
        git describe --exact-match HEAD || complete-build
    - deploy: |
        cd berfr.me
        make deploy
```

As you can see, the file is pretty simple. Here is a description of some of the
components:

- __image__: There is a
    [variety](https://man.sr.ht/builds.sr.ht/compatibility.md) of build images
    available on Sourcehut. Here, I am using `fedora/31` as it is what I am
    running locally and so the package versions used will be quite similar.
- __packages__: These extra packages will be installed using the distribution
    package manager. We only need `hugo` for building and `awscli` for
    deploying.
- __secrets__: By specifying the UUID of the secret created above, the aws
    credentials file will become available in the build environment.
- __tasks__: We have two tasks: build and deploy which simply call procedures
    declared in the Makefile. The `git describe --exact-match HEAD ||
    complete-build` line will prevent the execution of the deploy task if the
    latest commit is not an annotated tag.

The Makefile used is also easy to follow:

```Makefile
.PHONY: build deploy release

build:
	hugo --cleanDestinationDir --minify

deploy: build
	aws --region ca-central-1 --profile s3-berfr.me s3 sync public/ s3://berfr.me/ --delete

release: build
	git tag -s -a "`date +\"%y-%m-%d-%H-%M\"`" -m "`date`"
```

By using a Makefile, we can make changes to the commands needed in a single file
and use it both locally and in the build manifest. The same goes for specifying
a unique AWS profile name such as `s3-berfr.me`; we are able to use it in both
environments.

With these two files pushed to [git.sr.ht], the build should automatically start
and be visible at [builds.sr.ht]. To trigger a deployment, simply run `make
release` followed by `git push --follow-tags`.

[manifest]: https://man.sr.ht/builds.sr.ht/manifest.md
[git.sr.ht]: https://git.sr.ht
[builds.sr.ht]: https://builds.sr.ht

You can find the complete source code for this webite at
https://git.sr.ht/~berfr/berfr.me and the builds for it at
https://builds.sr.ht/~berfr/berfr.me/.build.yml. If you have any questions or
comments regarding this article, feel free to email me personally or write to my
[public inbox].

[public inbox]: https://lists.sr.ht/~berfr/public-inbox
