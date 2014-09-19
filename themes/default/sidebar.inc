<!-- tmpl_if name='all_tags' -->
<h2>Tags</h2>
<ul>
<!-- tmpl_loop name='all_tags' -->
 <li><a href="<!-- tmpl_var name='top' -->tags/<!-- tmpl_var name='tag' escape='html' -->"><!-- tmpl_var name='tag' escape='html' --> (<!-- tmpl_var name='count' -->)</a></li>
<!-- /tmpl_loop -->
</ul>
<!-- tmpl_else -->
<p>There are no tags.</p>
<!-- /tmpl_if -->
