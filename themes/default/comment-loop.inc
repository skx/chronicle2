<!-- tmpl_if name='comments' -->
 <h3>Comments On This Entry</h3>
 <blockquote>
 <!-- tmpl_loop name='comments' -->
  <div class="entry">
  <div class="title"><!-- tmpl_var name='name' --></div>
  <div class="date"><!-- tmpl_var name='date' --></div>
  <div class="body"><!-- tmpl_var name='body' --></div>
  </div>
 <!-- /tmpl_loop -->
 </blockquote>
<!-- /tmpl_if -->
