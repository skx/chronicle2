<h2><a href="<!-- tmpl_var name='top' --><!-- tmpl_var name='link' escape='html' -->"><!-- tmpl_var name='title' --></a></h2>
<!-- tmpl_if name='tags' -->
   <h6>Tags: <!-- tmpl_loop name='tags' --><a href="<!-- tmpl_var name='top' -->tags/<!-- tmpl_var name='tag' escape='html' -->"><!-- tmpl_var name='tag' escape='html' --></a><!-- tmpl_if name="__last__" -->.<!-- tmpl_else -->, <!-- /tmpl_if --><!-- /tmpl_loop --></h6>
<!-- /tmpl_if -->

    <!-- tmpl_if name='truncatedbody' -->
	<!-- tmpl_var name='truncatedbody' -->
    <!-- tmpl_else -->
    <!-- tmpl_var name='body' -->
    <!-- /tmpl_if -->
<p class="blog-list-detail">
Posted on <!-- tmpl_var name='date' --><!-- tmpl_if name='time' --> at <!-- tmpl_var name='time' --><!-- /tmpl_if --> -
  <!-- tmpl_if name='comment_count' --><a href="<!-- tmpl_var name='top' --><!-- tmpl_var name='link' escape='html' -->"><!-- tmpl_var name='comment_count' --> comment<!-- tmpl_if name='comment_plural' -->s<!-- /tmpl_if -->.</a> <!-- tmpl_else -->No comments <!-- /tmpl_if -->
</p>

