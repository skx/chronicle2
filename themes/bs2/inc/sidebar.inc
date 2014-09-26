<div class="panel">
<!-- tmpl_if name='recent_posts' -->
<h3>Recent Posts</h3>
 <ul class="unstyled recent-posts">
<!-- tmpl_loop name='recent_posts' -->
<li><b><!-- tmpl_var name='date' --></b>
<ul style="list-style:none;">
<li><a href="<!-- tmpl_var name='top' --><!-- tmpl_var name='link' -->"><!-- tmpl_var name='title' --></a></li>
</ul></li>
<!-- /tmpl_loop -->
</ul>
<!-- /tmpl_if name='recent_posts' -->

<h3>RSS Feed</h3>
<a href="/index.rss">RSS</a>
</div>
