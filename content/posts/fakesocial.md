---
title: 'fakesocial: Fake social network using generated content'
date: 2020-06-06
---

Last weekend, I released [fakesocial] ([source code]) after working on it for
the last few weeks and am pretty pleased with the result. Here, I will discuss a
few things about the project.

[fakesocial]: https://fakesocial.net
[source code]: https://github.com/berfr/fakesocial

To start with, fakesocial is a simple social network consisting of fake users
which have connections, make posts and also like and comment on these posts.
These user profiles use generated images as profile pictures and generated text
as posts and comments. The social network is then packaged as a website and
served on the internet.

## Data sources and content generation

The project is really just a collection of different sources of data packaged
with a nice web based user interface. For the profile pictures, images are taken
from the [This Person Does Not Exist] website which in turn uses [StyleGan] to
generate them. For the posts and comments, a simple [quotes dataset] is used in
addition to the [Markovify] package to generate new quotes from the dataset.
This package is also used with a [job titles dataset] to generate new job titles
for the fake users. The rest of the content on the fake social network is
generated from scrambling existing company, city and personal names.

Because the content on this website is generated using datasets, it is biased;
the images, posts, titles, etc. ultimately depend on the data that was used in
training the models. Even if [70,000 images] seems like a big number of images,
it is still not a complete representation of the humans of the world. It is
important to keep this in mind when viewing this project and looking at
generated content in general.

[This Person Does Not Exist]: https://thispersondoesnotexist.com
[StyleGan]: https://en.wikipedia.org/wiki/StyleGAN
[quotes dataset]: https://www.kaggle.com/coolcoder22/quotes-dataset
[Markovify]: https://github.com/jsvine/markovify
[job titles dataset]: https://github.com/jneidel/job-titles
[70,000 images]: https://github.com/NVlabs/ffhq-dataset

## Python and Vue.js

The generation of data is done using Python and [SQLAlchemy] using a local
[SQLite] database file. Using this file, new events are added using existing
events. For example, on an `add_comment` event, the program will fetch a post
that was previously added to which the comment will be added. With this setup,
it is possible to continue where we previously left off. Once the specified
number of events is reached, the Python program will generate a complete static
website suitable for hosting anywhere. The database is converted to a series of
JSON files that are loaded by the app front end.

The front end is implemented with [Vue.js] and [Vue Router] using a few simple
components. Using Vue Router, it is possible to link to user profiles and user
posts easily. For example, see [User 34] and [Post 1069]. The data files are
loaded as needed and so loading is quite fast.

This type of website generation is great since it can be hosted anywhere easily.
In our case, it is hosted using [GitHub Pages] which is free for public
repositories.

[SQLAlchemy]: https://www.sqlalchemy.org
[SQLite]: https://sqlite.org/index.html
[Vue.js]: https://vuejs.org
[Vue Router]: https://router.vuejs.org
[User 34]: https://fakesocial.net/#/user/34
[Post 1069]: https://fakesocial.net/#/post/1069
[GitHub Pages]: https://pages.github.com/

## What's next

I really like that there is no maintenance to do on this website because of the
way it is hosted. Also, it is not costing me anything to run except for the
domain registration which I may not renew next year. In that case, the website
will still be available at https://berfr.github.io/fakesocial.

I will probably run the `fakesocial` program a few times on the current database
file to generate more data in the next few weeks. I would also like to
experiment with other types of sentences files for post and comment content. If
you have any ideas or comments concerning fakesocial, feel free to open a pull
request, issue or email me!
