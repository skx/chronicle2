


<div id="comments">
<h3>Comments</h3>

  <!-- tmpl_loop name='comments' -->
  <div style="background-color: white; border: 1px solid grey; border-bottom: 4px solid grey; margin-bottom: 15px; padding:10px;">
  <div class="header">

  <table style="width:100%; border-bottom: 1px solid grey;">
  <tr><td width="50" style="text-align: center; vertical-align: middle;">
    <!-- tmpl_if name='author' -->
    <img alt="[author]" src="/spiral.gif" class="avatar" height="32" width="33" />
    <!-- tmpl_else name='author' -->
    <img alt="[gravitar]" src="<!-- tmpl_var name='gravitar' -->" class="avatar" height="32" width="33" />
    <!-- /tmpl_if name='author' -->
    </td>
    <td>
    <!-- tmpl_if name='link' -->
    <cite><a href="<!-- tmpl_var name='link' -->"><!-- tmpl_var name='name' --></a></cite>
    <!-- tmpl_else name='link' -->
    <cite><!-- tmpl_var name='name' --></cite>
    <!-- /tmpl_if name='link' -->
    </td>
</tr>
   <tr>
   <td></td><td>
    <p><!-- tmpl_var name='date' --></p>
</td></tr>
</table>

  </div>
    <div class="commentbody">
      <!-- tmpl_var name='body' -->
    </div>
  </div>

    <!-- /tmpl_loop -->
</div>