---
title: A first go at Go
date: 2020-07-26
---

This month, I wrote a first Go program. I had played around with the features of
the programming language a few times before but had never put together something
actually useful. Coming from a Python background, I thought it would be useful
to share my process and experience with others.

The app itself is a CLI RSS and Atom feed lister. It reads a file containing a
list of feed URLs and displays the posts from the last month. In this simple
project, I was able to use and understand [Goroutines] and [Channels] more in
depth.

[Goroutines]: https://tour.golang.org/concurrency/1
[Channels]: https://tour.golang.org/concurrency/2

The project uses the [github.com/mmcdole/gofeed] external Go library for
fetching and parsing feeds of different types. To use it, I simply read the
Basic Usage section of the README file of the project and then used the online
[docs] to get more specific information about the different types and their
methods.

[github.com/mmcdole/gofeed]: https://github.com/mmcdole/gofeed
[docs]: https://pkg.go.dev/github.com/mmcdole/gofeed?tab=doc

This simple program, with almost 100 lines of Go code, took me about 5 to 6
hours in total to complete. When I first learned Python, this type of project
would have taken me about an hour of work and would have contained way less code
(assuming there is an equivalent high level feed parser Python package
available). In my experience, developing in Python is so quick because of the
interactive interpreter. When exploring new modules or even testing stuff in the
language itself, I often start my script with `python -i ...` and then I am able
to easily explore the environment. With Go however, when testing stuff out, you
need to compile every time and then try to understand why it did not compile.
Also, to view available types and methods available in modules, you need to look
at the docs, something i've almost never had to do in Python. I'm sure though
that these small difficulties are solved by using a smarter development
environment.

I am aware also that it is just a matter of tradeoffs. The time you need to
spend in advance in Go to think about types will save you time later on when the
program becomes larger and harder to maintain. Also, the execution time decrease
is huge when using Go as opposed to Python. I also have to mention that it would
have taken much less time to implement had I not used concurrency in my Go
program; these concepts took me a while to grasp and get working.

For me, the reason to start exploring and understanding Go more is about the
industry use of it. It seems that more and more companies and open source
projects are built using Go and being able to develop in it is certainly going
to be useful. I am confident that my Go skills will get better with time and
practice and that simple projects like these will be much faster to create.
