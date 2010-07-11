opt_content = <<EOS
title: Test Site
author: John Doe
layout: main
EOS

index_content = <<EOS
---
title: The Home Page
---

Well you might want to change this!
EOS

layout_content = <<EOS
<!DOCTYPE html>  
<html lang="en">  
  <head>  
    <meta charset="utf-8" />  
    <title>{{ site.title }}</title>
  </head>  
  <body>
  
    {{ yield }}
    
    <h4>A List of Posts</h4>
    <ul>
      {% for post in site.posts %}
        <li><a href="{{ post.url }}">{{ post.title }}</a> - {{ post.date }}</li>
      {% endfor %}
    </ul>
    
    <span>Copyright &copy; {{ site.author }}</span>
  </body>  
</html> 
EOS

post_content = <<EOS
---
title: Hello World
date: #{Time.now.strftime("%Y-%m-%d at %H:%M:%S")}
tags: test, hello
---

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.  
EOS