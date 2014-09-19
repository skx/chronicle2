<!-- tmpl_if name='all_tags' -->
<h3>All Tags</h3>
<ul>
<!-- tmpl_loop name='all_tags' -->
<li><a href="<!-- tmpl_var name='top' -->tags/<!-- tmpl_var name='tag' -->"><!-- tmpl_var name='tag' --></a></li>
<!-- /tmpl_loop -->
</ul>
<!-- /tmpl_if -->