Henshin gives your templates access to certain data as described below. __Note:__ I will be using liquid tags below, but the information should be valid for whatever layout style you are using.


## Global

    site
    yield
    post
    gen


## Site

    author
    title
    description
    time_zone
    created_at
    posts
    tags
    categories
    archive
    

## Post

    title
    author
    permalink
    url
    date
    category
    tags
    content


## Gen

    title
    permalink
    url
    content


## Tag

    name
    posts
    url


## Categories

    name
    posts
    url


## Archive

    [year].posts
    [year][month].posts
    [year][month][date].posts