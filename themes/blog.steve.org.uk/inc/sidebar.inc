<p style="text-align: center;"><img src="/spiral.gif" width="68" height="68" alt="Spiral Logo"/></p>

<!-- tmpl_if name='recent_posts' -->
<h3>Recent Posts</h3>
<ul>
<!-- tmpl_loop name='recent_posts' -->
<li><b><!-- tmpl_var name='date' --></b>
<ul>
<li><a href="<!-- tmpl_var name='top' --><!-- tmpl_var name='link' -->"><!-- tmpl_var name='title' --></a></li>
</ul></li>
<!-- /tmpl_loop -->
</ul>
<!-- /tmpl_if name='recent_posts' -->

<h3>Links</h3>
<ul style="list-style:none;">
 <li><a href="/about/">About</a></li>
 <li><a href="/archive/">Archive</a></li>
 <li><a href="/tags/">Tags</a></li>
</ul>

<h3>Search</h3>
<p>Search prior entries:</p>
 <form method="get" action="/cgi-bin/search/namazu.cgi">
    <input type="text" name="query" />
    <input type="hidden" name="submit" value="Search"/>
    <input type="hidden" name="max" value="30" />
    <input type="hidden" name="sort" value="score" />
  </form>

<h3>RSS Feed</h3>
<ul style="list-style:none;">
 <li><a href="/index.rss"><img src="/xml.gif" alt="Subscribe to feed" width="36" height="14" /></a></li>
</ul>