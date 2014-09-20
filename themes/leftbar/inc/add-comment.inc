<!-- tmpl_if name='comments_enabled' -->
<script type="text/javascript" src="/js/jquery-1.11.1.min.js">
</script>
<blockquote>
<div id="output">
  <h3>Add A Comment</h3>
  <blockquote>
    <form action="/cgi-bin/comments.cgi" id="cform" name="cform" method="POST" accept-charset="utf-8">
      <input type="hidden" name="id" value="<!-- tmpl_var name='link' escape='html' -->" />
      <input type="hidden" name="robot" id="robot" value="" />
      <input type="hidden" name="frosty" id="frosty" value="&#9731;">
      <table>
        <tr><td><b>Name</b>:</td>
          <td><input type="text" size="55" name="name" /></td></tr>
        <tr><td><b>Email</b>:</td>
          <td><input type="text" size="55" name="mail" /></td></tr>
        <tr><td><b>Website</b>:</td>
          <td><input type="text" size="55" name="link" /></td></tr>
        <tr><td colspan="2"><b>Your Comment</b><br />
            <textarea name="body" rows="10" cols="60"></textarea></td></tr>
        <tr><td></td><td align="right"><input type="submit" name="submit" value="Post Comment"/></td></tr>
      </table>
    </form>
<div id="progress" style="display: none;">
<p>Submitting .. <img src="progress.gif"></p>
</div>
    <p>Your submission will be ignored if the name, email, or comment field is left blank.</p>
    <p>Your email address will <b>never</b> be displayed, but your homepage will be.</p>
  </blockquote>
</div>
</blockquote>

<script type="text/JavaScript">
<!--
    /**
     * Progress On.
     */
    $(document).ajaxStart(function() {
	    $("div#progress").show();
    });

    /**
     * Progress off.
     */
    $(document).ajaxComplete(function() {
	    $("div#progress").hide();
    });

    /**
     * Bind the magic.
     */
    $(document).ready(function(){
       $("#cform").submit(function(){
           var data = $("#cform").serialize();
           data = data + "&ajax=1";

           $.ajax({
	        type: "POST",
	        url: "/cgi-bin/comments.cgi",
	        data: data,
	        success: function(data) {
	                $("#output").html( data );
	            }
	        });

           return false;
       });
    });
  -->
</script>


<!-- tmpl_else name='comments_enabled' -->
<blockquote><blockquote>
<p>Comments are closed on posts which are more than ten days old.</p>
</blockquote></blockquote>
<!-- /tmpl_if -->
