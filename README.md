# Henshin

Henshin is at it's most basic level a static site generator. It takes a folder of files
and layouts, combining them to create a web site that can be put on a web server. It provides
a basic Site generator and a Blog generator which easily handles tags, categories and 
archives.


## Summary

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


## What's `Henshin::Base`?

I built henshin to be as loosely defined at it's core as possible so that it is easy to build
more specialised "site builders" from it. At the core of Henshin is the class `Henshin::Base`,
the other included builders, `Henshin::Site` and `Henshin::Blog`, are both subclasses of it.
Each of these are made for specific tasks and you can choose which to use by setting a the `type`
in `config.yml`. For instance to use `Henshin::Site` instead of the default `Henshin::Blog` I 
would add:

    type: site

You are not limited to the three that I have written either, it is simple to create your own 
subclass as explained later @todo[ADD LINK].


## Structure

The structure of a site will usually be similar to this.

    .
    ├── _site               # where the built site goes
    ├── config.yml          # settings for the site, see @todo[ADD LINK]
    ├── css
    │   └── screen.sass
    ├── index.liquid
    └── layouts             # layouts used when rendering
        └── main.liquid

Henshin supports various file formats out of the box, and obviously can be extended @todo[ADD LINK],
I am only going to list the formats not document them fully!

- [builder (.builder)](http://builder.rubyforge.org/)
- [coffeescript (.coffee)](http://jashkenas.github.com/coffee-script/)
- [erb (.erb, .rhtml)](http://www.ruby-doc.org/stdlib/libdoc/erb/rdoc/)
- [haml (.haml)](http://haml-lang.com/)
- [markdown (.markdown, .mkd, .md)](http://daringfireball.net/projects/markdown/) using [kramdown](http://kramdown.rubyforge.org/) or [maruku](http://maruku.rubyforge.org/) or [rdiscount](https://github.com/rtomayko/rdiscount)
- [liquid (.liquid)](http://www.liquidmarkup.org/)
- [nokogiri (.nokogiri)](http://nokogiri.org/)
- [rdoc (.rdoc)](http://rdoc.sourceforge.net/)
- [textile (.textile)](http://textile.thresholdstate.com/) using [redcloth](http://redcloth.org/)
- [sass (.sass)](http://sass-lang.com/)
- [scss (.scss)](http://sass-lang.com/)
- [slim (.slim)](http://slim-lang.com/)

As is shown in the list henshin supports 3 different markdown libraries, by default maruku will be used
but you can select either by adding `markdown: rdiscount` or `markdown: kramdown` to your `config.yml`.

It also supports syntax highlighting using as native looking as possible syntax for the templating language
being used, so here is a table with the languages and how to use (replace language with the name of the language
__note__ the different prefixes for certain templates).

    Language                  Syntax
    ---------------------------------------------------------
    builder, sass, scss, 
    coffeescript              [no support]
    
    erb                       <% highlight :language do %>
                                ...your code...
                              <% end %>
                              
    haml                      :highlight
                                $language
                                ...your code...
    
    liquid                    {% highlight language %}
                              ...your code...
                              {% endhighlight %}
    
    nokogiri                  [no support]
    
    redcloth                  highlight. language
                              ...your code...
                              
                              Back to normal text, blank line required to end the code block!
    
    slim                      I've forgotten have a look! @todo
    
    kramdown, maruku, 
    rdiscount, rdoc           $ highlight language
                              ...your code...
                              $ end

### Blog

For a blog the only change you __must__ make is to a `post` folder. In this you can add posts
as you would any other file, with one difference each post __must__ have a date. The date can
be set in the yaml frontmatter of implied by the folders it is saved in, eg. the post 
`./posts/2010/12/31/new-years-eve-already.md` would have the date set as 2010-12-31, though
it would still be possible to override this by adding to the yaml: `date: 2011-01-01 00:01`.
    

* * *



# Henshin

Henshin is a static site generator. It takes in posts, or just pages, runs them 
through plugins and layouts and gives you a folder to put on a webserver. It 
makes it easy to write archive pages, tags and categories.


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
