---
layout: default
title: Release History
---
<h2>
	Release history
</h2>

{% for post in site.posts %}
<div class="release">
  {{ post.content }}
</div>
{% endfor %}
