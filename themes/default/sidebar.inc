<!-- tmpl_if name='archived_posts' -->
<h3>Archived Posts</h3>
<ul>
<!-- tmpl_loop name='archived_posts' -->
<li><a href="<!-- tmpl_var name='top' -->archive/<!-- tmpl_var name='year' -->"><!-- tmpl_var name='year' --></a>
<ul>
<!-- tmpl_loop name='months' -->
<li><a href="<!-- tmpl_var name='top' -->archive/<!-- tmpl_var name='year' -->/<!-- tmpl_var name='month' -->"><!-- tmpl_var name='month_name' --> (<!-- tmpl_var name='count' -->)</a></li>
<!-- /tmpl_loop name='months' -->
</ul></li>
<!-- /tmpl_loop -->
</ul>
<!-- /tmpl_if -->


<!-- tmpl_if name='all_tags' -->
<h3>All Tags</h3>
<ul>
<!-- tmpl_loop name='all_tags' -->
<li><a href="<!-- tmpl_var name='top' -->tags/<!-- tmpl_var name='tag' -->"><!-- tmpl_var name='tag' --></a></li>
<!-- /tmpl_loop -->
</ul>
<!-- /tmpl_if -->