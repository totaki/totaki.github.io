---
layout: post
title:  "Create element for html page"
date:   2015-11-17
tags:   js html
---
This module help create page elements with id, classes, childs and  
call some function on element after create.

<section class="post-tags">
  {% for item in page.tags %}
    <a href="/en/solutions/{{ item }}/">{{ item }}</a>
  {% endfor %}
</section>

{% gist totaki/17a28a4ee3326e57373a %}
