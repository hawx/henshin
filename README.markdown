# Henshin

Henshin is a new static site generator, yeah another one. I wasn't going to release it yet but then I saw [awestruct](http://awestruct.org/) and thought I may as well now. Oh and this was totally inspired by the amazing [jekyll](http://github.com/mojombo/jekyll) (in case you hadn't guessed).


## Main Features

- Generates posts, etc.
- More control with settings (see below)
- A plugin system (not great at the moment, still working on how best to implement it)

## Future Goals

- Ability to regenerate only files that have changed
- Easy tag, category and archive pages
- Default templates so you can just type `henshin` with any folder of text files and create a quick site


## How To

Install by typing `(sudo) gem install henshin`

Then create a folder for your site, in this you'll probably want to create two folders `layouts` and `posts`, to put in your layouts and posts.

Next create an `index.html` file and your kind of done, unless of course you want some content.

Build the site by running `henshin` from the command line. Help available with `henshin -h`

### YAML Frontmatter & Options.yaml

You can create an optional `options.yaml` file at the root of your site, here are the options so far:

    title: [title of your site]
    description: [description for your site]
    author: [your name]
    
    layout: [the default layout to use]
    
    post_name: [the way the post name is parsed]
      eg. '{title-with-dashes}.{extension}
      
        you can use:
          {title}
          {title-with-dashes}
          {date}
          {date-time}
          {extension}
          
    permalink: [the way you want the permalink to look]
      eg. '/{year}/{month}/{date}-{title}/index.html
        these are the only options at the moment for permalink
      
    plugins: [array of plugins to 
    

### Plugins

The only plugins at the moment are the ones included (liquid, maruku, sass and pygments) of which only liquid and maruku work at the moment. In the future you will be able to add your own plugins, probably in a plugins folder. If you want to make your own just look at the others, it's pretty simple to work out!


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