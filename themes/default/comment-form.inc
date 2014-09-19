<!-- tmpl_if name='comments_enabled' -->
<h3>Add A Comment</h3>
<blockquote>
<form action="/cgi-bin/comments.cgi" method="post">
<input type="hidden" name="id" value="<!-- tmpl_var name='link' escape='html' -->">
<input type="hidden" name="captcha" value="">
<table>
<tr><td>Your Name</td>
    <td><input type="text" size="55" name="name"></td></tr>
<tr><td>Your EMail</td>
    <td><input type="text" size="55" name="mail"></td></tr>
<tr><td colspan="2">Your Comment<br />
<textarea name="body" rows="10" cols="60">
</textarea></td></tr>
<tr><td></td><td><input type="submit"></td></tr>
</table>
</form>
<p>Your submission will be ignored if any field is left blank.  But your email address will not be displayed.</p>
</blockquote>
<!-- /tmpl_if -->
