# Henshin

__NOTE:__ this is a work-in-progress. It should be safe to use to build your
blog but don't go trying to hack the internals because stuff __will__ change.

Henshin, should have been called yassg. It's a static site generator, focused on
bloggin' and focused in general.


## Usage

``` bash
$ gem install henshin
$ henshin new my_blag
$ cd my_blag
$ ls
assets/    config.yml  drafts/    index.slim  media/    posts/    templates
$ henshin view
...
```

Henshin can upload your site using sftp, to set it up just add,

``` yaml
publish:
  host: sftp.myserver.com
  base: /path/to/public
  user: my_username
  pass: my_password
```

You can omit pass, in which case you will be prompted for it when publishing.
Then you can type:

``` bash
$ henshin publish
```

To upload your site.


## Structure

### config.yml

Contains the configuration data for your blog, you can put anything in here and
it will be available in templates under the `site` prefix. For example if you
set `bio: Hi ...` you can use `site.bio` in your templates. Useful options:

* title - give your site a name
* root - allows your site to be built into a subfolder

### templates

Templates, by default files will use the template called, ...drum roll...,
"default". If it exists posts will try to use the template called "post".

### posts

These are your published posts, the title/date etc. are __not__ taken from the
filename so feel free to call the files what you want, I put a number in front
so I know the order without having to put the whole date in. Date/title/etc. are
taken from the yaml frontmatter of the post.

### drafts

These are unfinished posts and will not be put in your built site. They are
shown when previewing your site, so you can see what it will look
like.

### assets

Assets contains scripts and stylesheets, throw any coffeescript/javascript in
`scripts` and any sass/css in `styles`, they will then be magically compiled,
collected and minimised (soon!). All the files in `scripts` become `script.js`
and the files in `styles` become `style.css`. Simple!

### media

Put any media in here, it will be copied along verbatim. Really you could delete
this and create a folder called `images` or whatever.


## Choices

I said it was focused. You get:

- Coffeescript with [ruby-coffee-script][rcs]
- Markdown with [redcarpet][rc]
- [Sass][sss]
- [Slim][slm]
- Code highlighting with [SyntaxHighlighter][sh]

[rcs]: https://github.com/josh/ruby-coffee-script
[rc]:  https://github.com/tanoku/redcarpet
[sss]: http://sass-lang.com/
[slm]: http://slim-lang.com/
[sh]:  http://alexgorbatchev.com/SyntaxHighlighter/


## Extending

Henshin isn't a static-blog-generator it's a static-site-generator with
blogginess bolted on. This means it should be possible to extend in such a way
that it fits your problem. Check out these classes depending on what you need to
do:

- Site, the orchestrator
- AbstractFile, a virtual file
- File, a physical file
- Writer, writes to local file system (`henshin build`)
- Publisher, writes to remote file system (`henshin publish`)
- Engine, renders text
