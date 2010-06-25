Henshin makes it easy to create tag pages, archives and category pages. All you need to do to enable these is create layouts for them, it will only use the layouts you provide so if you don’t want an archive for each day don’t create the layout.

    archive_date.html -> shows the posts on a particular day
    archive_month.html -> shows the posts in a particular month
    archive_year.html -> shows the posts in a particular yeas
    category_index.html -> shows all categories
    category_page.html -> shows posts for particular category
    tag_index.html -> shows all tags
    tag_page.html -> shows posts for particular tag


#### Archives

Specific tags are available to use in archive pages, these are.

    archive.date -> the full date, if part of date is not available the date will be taken 
                      from xxxx/01/01 00:00 (because the year will always be available)
    archive.posts -> a list of posts, which can be used as expected


#### Category and Tags

The specific tags for use in tags and archives are exactly the same, just use category instead of tag.

    site.categories -> a list of categories
    site.categories[I].name -> name of the category
    site.categories[I].posts -> a list of posts, which can be iterated over as expected

Look at `test/site/layouts` for an example.