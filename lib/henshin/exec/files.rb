module Files

  module Archive
    def self.date
      r = <<EOS
<!DOCTYPE html>  
<html lang="en">  
  <head>  
    <meta charset="utf-8" />  
    <title>{{ site.title }}</title>
  </head>  
  <body>
    <h1>Archive for {{ archive.year }}/{{ archive.month }}/{{ archive.day }}</h1>
    
    <ul>
      {% for post in archive.posts[archive.year][archive.month][archive.day] %}
        <li><a href="{{ post.url }}">{{ post.title }}</a></li>
      {% endfor %}
    </ul>
  </body>  
</html> 
EOS
    end
    
    def self.month
      r = <<EOS
<!DOCTYPE html>  
<html lang="en">  
  <head>  
    <meta charset="utf-8" />  
    <title>{{ site.title }}</title>
  </head>  
  <body>
    <h1>Archive for {{ archive.year }}/{{ archive.month }}</h1>

    <ul>
      {% for day in (1..31) %}
        {% if archive.posts[archive.year][archive.month][day] %}
          {% for post in archive.posts[archive.year][archive.month][day] %}
            <li><a href="{{ post.url }}">{{ post.title }}</a></li>
          {% endfor %}
        {% endif %}
      {% endfor %}
    </ul>
  </body>  
</html> 
EOS
    end
    
    def self.year
      r = <<EOS
<!DOCTYPE html>  
<html lang="en">  
  <head>  
    <meta charset="utf-8" />  
    <title>{{ site.title }}</title>
  </head>  
  <body>
    <h1>Archive for {{ archive.year }}</h1>

    <ul>
      {% for day in (1..31) %}
        {% for month in (1..12) %}
          {% if archive.posts[archive.year][month][day] %}
            {% for post in archive.posts[archive.year][month][day] %}
              <li><a href="{{ post.url }}">{{ post.title }}</a></li>
            {% endfor %}
          {% endif %}
        {% endfor %}
      {% endfor %}
    </ul>
  </body>  
</html>
EOS
    end
  end
  
  module Tag
    def self.index
      r = <<EOS
<!DOCTYPE html>  
<html lang="en">  
  <head>  
    <meta charset="utf-8" />  
    <title>{{ site.title }} > Tags</title>
  </head>  
  <body>  
    <h2>A List of Tags</h2>
    <ul>
      {% for tag in site.tags %}
        <li>
          <a href="{{ tag.url }}">{{ tag.name }}</a>
          <ul>
          {% for post in tag.posts %}
            <li><time>{{ post.date | date_to_string }}</time> - <a href="{{ post.url }}">{{ post.title }}</a></li>
          {% endfor %}
          </ul>
        </li>
      {% endfor %}
    </ul>
  </body>  
</html> 
EOS
    end
    
    def self.page
      r = <<EOS
<!DOCTYPE html>  
<html lang="en">  
  <head>  
    <meta charset="utf-8" />  
    <title>{{ site.title }} > {{ tag.name }}</title>
  </head>  
  <body>
    <h2>{{ tag.name }}</h2>
    <ul>
    {% for post in tag.posts %}
      <li><time>{{ post.date | date_to_string }}</time> - <a href="{{ post.url }}">{{ post.title }}</a></li>
    {% endfor %}
    </ul>
  </body>  
</html> 
EOS
    end
  end
  
  module Category
    def self.index
      r = <<EOS
<!DOCTYPE html>  
<html lang="en">  
  <head>  
    <meta charset="utf-8" />  
    <title>{{ site.title }} > Categories</title>
  </head>  
  <body>
    <h2>A List of Categories</h2>
    <ul>
      {% for category in site.categories %}
        <li>
          <a href="{{ category.url }}">{{ category.name }}</a>
          <ul>
          {% for post in category.posts %}
            <li><time>{{ post.date | date_to_string }}</time> - <a href="{{ post.url }}">{{ post.title }}</a></li>
          {% endfor %}
          </ul>
        </li>
      {% endfor %}
    </ul>
  </body>  
</html> 
EOS
    end
    
    def self.page
      r = <<EOS
<!DOCTYPE html>  
<html lang="en">  
  <head>  
    <meta charset="utf-8" />  
    <title>{{ site.title }} > {{ category.name }}</title>
  </head>  
  <body>   
    <h2>{{ category.name }}</h2>
    <ul>
    {% for post in category.posts %}
      <li><time>{{ post.date | date_to_string }}</time> - <a href="{{ post.url }}">{{ post.title }}</a></li>
    {% endfor %}
    </ul>
  </body>  
</html> 
EOS
    end
  end

  def self.options
    r = <<EOS
title: Test Site
layout: main
EOS
  end
  
  def self.index 
    r = <<EOS
---
title: The Home Page
---

Well you might want to change this!

<h4>A List of Posts</h4>
<ul>
  {% for post in site.posts %}
    <li><a href="{{ post.url }}">{{ post.title }}</a> - {{ post.date }}</li>
  {% endfor %}
</ul>

EOS
  end
  
  def self.layout
    r = <<EOS
<!DOCTYPE html>  
<html lang="en">  
  <head>  
    <meta charset="utf-8" />  
    <title>{{ site.title }}</title>
  </head>  
  <body>{{ yield }}</body>  
</html> 
EOS
  end
  
  def self.post
    r = <<EOS
---
title: Hello World
date: #{Time.now.strftime("%Y-%m-%d at %H:%M:%S")}
tags: [test, hello]
---

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.  
EOS
  end
end