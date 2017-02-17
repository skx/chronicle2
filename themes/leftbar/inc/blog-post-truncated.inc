<div>
  <h2 style="width:100%; border-bottom:1px solid silver;"><a href="<!-- tmpl_var name='top' --><!-- tmpl_var name='link' escape='html' -->" style="text-decoration:none; color:black;"><!-- tmpl_var name='title' --></a></h2>
  <p style="text-align:right; width:100%"><!-- tmpl_var name='date' --><!-- tmpl_if name='time' --> at <!-- tmpl_var name='time' --><!-- /tmpl_if --></p>
  <div class="entry-content">
  <!-- tmpl_if name='truncatedbody' -->
    <!-- tmpl_var name='truncatedbody' -->
  <!-- tmpl_else -->
    <!-- tmpl_var name='body' -->
  <!-- /tmpl_if -->
  </div>
  <p style="text-align:right;width:100%">
    <span class="entry-category">
      <!-- tmpl_if name='tags' -->
      Tags: <!-- tmpl_loop name='tags' --><a href="<!-- tmpl_var name='top' -->tags/<!-- tmpl_var name='tag' escape='html' -->"><!-- tmpl_var name='tag' escape='html' --></a><!-- tmpl_if name="__last__" -->.<!-- tmpl_else -->, <!-- /tmpl_if --><!-- /tmpl_loop -->
      <!-- tmpl_else -->
      No tags
      <!-- /tmpl_if -->
    </span>
    <span class="meta-sep">|</span>
    <span class="entry-comments">
      <!-- tmpl_if name='comment_count' -->
      <a href="<!-- tmpl_var name='top' --><!-- tmpl_var name='link' escape='html' -->"><!-- tmpl_var name='comment_count' --> comment<!-- tmpl_if name='comment_plural' -->s<!-- /tmpl_if -->.</a>
      <!-- tmpl_else -->
      No comments
      <!-- /tmpl_if -->
    </span>
    </p>
</div>
<p>&nbsp;</p>
