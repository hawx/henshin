## Creating a New Site

Henshin allows you to easily create a new site.

    cd [some directory]
    henshin create

This automatically creates the correct directory structure and dummy files.


## Setup

In your new site you can override the default options by creating/editing `options.yaml` at the root of your site.
These are the options you can use:

    title: Title of your site
    description: Description for your site
    author: The author of the site
    layout: The default layout to use
    post_name: (see below)
    permalink: (see below)
    plugins: A list of plugins to load


#### Post Name

This describes how the name of your posts should be parsed, which is probably best explained through an example...

    mysite/posts/2010-09-15-Lorem-Ipsum.markdown
    -> use
    post_name: "{date}-{title-with-dashes}.{extension}"

Here's a list of the different tokens to use

    {title} - title of the post
    {title-with-dashes} - title of the post, if you use dashes in it
    {date} - the date of the post, eg. 2010-12-31
    {date-time} - date and time for the post, eg. 2010-12-31T12:15
    {extension} - the posts extension, must be used
    {category} - the posts category

If you want to use something like `category/title.extension` for some posts but not all posts will have a specific category it is possible to make that optional by surrounding it with `<>`, eg. 

    post_name: '<{category}/>{title-with-dashes}.{extension}'


#### Permalink

This describes where the post should be put when generated, its permalink. It's pretty similar to `post_name`, but with different tokens.

    {year}, {month}, {date}, {title}, {category}

So for example...

    permalink: '{year}/{month}/{date}/{title}.html'
    -> or pretty urls
    permalink: '{year}/{month}/{date}/{title}/index.html'
