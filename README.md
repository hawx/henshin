# Henshin

Henshin is at it's most basic level a static site generator. It takes a folder of files
and layouts, combining them to create a web site that can be put on a web server. It provides
a basic Site generator and a Blog generator which easily handles tags, categories and 
archives.

## How To

Install with (requires ruby 1.9.x)

    (sudo) gem install henshin

Then create a basic skeleton site

    cd [some directory]
    henshin create
    # or henshin create blog

And build the site with

    henshin

You can even serve it using

    henshin serve
    

******************************************************



# Henshin

Henshin is a static site generator. It takes in posts, or just pages, runs them through plugins and layouts and gives you a folder to put on a webserver. It makes it easy to write archive pages, tags and categories.


## How To

Install with

    (sudo) gem install henshin

Then create a new site

    cd [some directory]
    henshin create

And build your new site with

    henshin


## Setup

The basic file system setup for a site will look like this,

    /css
      [stylesheets]
    /layouts
      main.liquid [or similar]
    index.liquid [or similar]
    

## Configuration

### Loading Files

In your config.yml add an item (or array) for the key `load`, these files will then be evaluated within
the context of the current site (or blog, etc.) That means you have access to methods such as `before` and
`after` to define extra behaviour.



## Note on Patches/Pull Requests

- Fork the project
- Make your feature addition or bug fix
- Add tests for it. This is important so I don't break it in a
  future version unintentionally.
- Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
- Send me a pull request. Bonus points for topic branches.


## License

Copyright (c) 2010 Joshua Hawxwell. See LICENSE for details.