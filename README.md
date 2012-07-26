# Henshin

Yes it's another static site generator. Out of the box it's set up for blogging
but henshin is so flexible and configurable it is useful in most situations
where you need to generate a static site from some data.


## Usage

First install the gem (it requires ruby 1.9.3),

``` bash
$ gem install henshin
```

Next create an empty site,

``` bash
$ henshin new my_site
```

Now we can start a server to view the site,

``` bash
$ cd my_site
$ henshin view
...
```

Henshin rebuilds the pages when requested so edit `index.slim.html` and reload
the page now.

To build the site into the `build` folder, run:

``` bash
$ henshin build
```

But one of the key features of henshin is that you (probably) __never__ need to
run `henshin build`. Henshin can upload your site straight to a server using
sftp. To set it up you just need to add this to the `config.yml` file,

``` yaml
publish:
  host: sftp.myserver.com
  base: /path/to/public
  user: username
```

And when running `henshin publish` you will be prompted for the password.


## Structure

Sites have a lot in common. Henshin forces some conventions but not too many.

### ./config.yml

Contains configuration and data for your site. Anything in here is accessible in
templates and files. For instance you could add,

``` yaml
likes:
- Italian food
- Football
- ...
```

So that you can add a list of things you like to the homepage,

``` slim
ul
  h1 I like
  - for like in site.likes
    li = like
```

### ./init.rb

This file lets you alter Henshin in any way you imagine.

### ./posts/

These are your published posts. They must contain yaml frontmatter with at least
title and date attributes.

``` md
---
title:  My First Post
date:   2012-01-01
---

So, ...
```

### ./drafts/

These are your unpublished posts and will not be in your built site. They are
shown when previewing your site with `henshin view` so it is easy to see what
they will look like when finished.

### ./templates/

Most files will try to use a template, the default template used is called
"default", posts will attempt to use the "post" template if it exists. And you
can force a file to use a different template by setting `template:` in the
yaml frontmatter, for instance

``` md
---
...
template: strange
---
...
```

### ./assets/scripts/

Contains scripts (these can be javascript or coffeescript). They are combined
and minimised when you build your site.

### ./assets/styles/

Contains stylesheet files (css, sass, scss or less files). Like scripts they are
combined and minimised when you build your site.


## Configuration


## Extending/Hacking

...
