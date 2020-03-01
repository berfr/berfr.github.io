---
title: 'watch-diff: Watch command output and get notified on changes'
date: 2020-03-01
---

For a few months now, I have been using my
[`watch-diff`](https://github.com/berfr/watch-diff) project to get notified on
command output changes. The beauty of this simple tool is that it works with any
command that can be executed in the shell. This means that once you figure out
the exact command you need to monitor, you simply plug it into `watch-diff` and
you automatically get email notifications on updates.

## Example: monitoring current releases

Here is the output for monitoring the current version of this package on the
PyPI website while a release is being made:

```diff
$ watch-diff "curl -s https://pypi.org/project/watch-diff/ | \
    sed -n '/<h1 class=\"package-header__name\">/,/<\/h1>/p'"
[2020-03-01 01:04:11.697054] first_run:
      <h1 class="package-header__name">
        watch-diff 1.0.2
      </h1>
[2020-03-01 01:04:16.839766] no diff
[2020-03-01 01:04:21.986465] no diff
[2020-03-01 01:04:27.122121] no diff
[2020-03-01 01:04:32.278194] no diff
[2020-03-01 01:04:37.424123] diff:
--- Previous    2020-03-01 01:04:32.278194
+++ Current     2020-03-01 01:04:37.424123
@@ -1,3 +1,3 @@
       <h1 class="package-header__name">
-        watch-diff 1.0.2
+        watch-diff 1.0.3
       </h1>
[2020-03-01 01:04:42.710685] no diff
...
```

## No extra dependencies

This Python package does not require any extra PyPI packages to function.
Instead, it relies on a few packages from the Standard Library. These include:

- [`argparse`]: Handle arguments passed to the CLI command.
- [`datetime`]: Manage timestamps for command runs.
- [`email`]: Used to add multiple parts and message IDs to email.
- [`smtplib`]: Communication with SMTP server.
- [`subprocess`]: Calling the actual command and reading the output.

[`argparse`]: https://docs.python.org/3/library/argparse.html
[`datetime`]: https://docs.python.org/3/library/datetime.html
[`email`]: https://docs.python.org/3/library/email.html
[`smtplib`]: https://docs.python.org/3/library/smtplib.html
[`subprocess`]: https://docs.python.org/3/library/subprocess.html

Since there aren't any additional packages installed with `watch-diff`, there
isn't much danger in installing it globally with `pip` as a regular user. This
has the advantage of being able to call it from wherever without having to worry
about a virtual environment.

```shell
# install as user in home directory
pip install --user watch-diff
```

## Email thread handling

By setting the `Message-ID` and `In-Reply-To` in the emails sent, they are
easily grouped together in their respective runs. This makes it possible to
start multiple instances of `watch-diff` all watching different commands while
keeping a tidy inbox.

```text
Mar 01 2020 watch-diff (2.8K)   ┌─>
Mar 01 2020 watch-diff (2.9K) ┌─>watch-diff diff: ls -la
Mar 01 2020 watch-diff (7.5K) watch-diff first_run: ls -la
Mar 01 2020 watch-diff (1.6K)                   ┌─>
Mar 01 2020 watch-diff (1.6K)                 ┌─>
Mar 01 2020 watch-diff (1.6K)               ┌─>
Mar 01 2020 watch-diff (1.6K)             ┌─>
Mar 01 2020 watch-diff (1.6K)           ┌─>
Mar 01 2020 watch-diff (1.6K)         ┌─>
Mar 01 2020 watch-diff (1.6K)       ┌─>
Mar 01 2020 watch-diff (1.6K)     ┌─>
Mar 01 2020 watch-diff (1.6K)   ┌─>
Mar 01 2020 watch-diff (1.6K) ┌─>watch-diff diff: date
Mar 01 2020 watch-diff (1.3K) watch-diff first_run: date
```

## Configuration

Configuration of `watch-diff` is only needed if the `-r/--recipient` option is
used. This triggers email notifications and so SMTP settings are needed. If
used, the program will either prompt the user for the needed values or use the
ones set in environment variables if available. The following variables are
used:

- `SMTP_HOST`
- `SMTP_PORT`
- `SMTP_USER`
- `SMTP_PASS`

These can be exported in the `~/.bashrc` file so they are available at any time.

A good strategy for more secure configuration is to create an email account that
is used exclusively for sending emails. If the credentials get compromised, it
is has less impact than if your main email credentials get stolen. Also, it is a
good idea to use `secret-tool lookup ...` to get the SMTP password so that it is
not written in plain text in a config file.

## Further work

I am very satisfied with this tool right now; it is super simple to use with
whatever shell command, the emails are tidy and they look good. If you have any
issues or want to suggest or contribute a feature, feel free to contact me!
