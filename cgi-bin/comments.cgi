#!/usr/bin/perl -w
#
#  This is a simple script which is designed to accept comment requests,
# and save the details to local text files upon the localhost.
#
#  This code is very simple and should be easy to extend with anti-spam
# at a later point.
#
#
###
#
#   NOTE:  If you wish to use this you must edit three things at the
#         top of the script.
#
#          1.  The directory to save the comment data to.
#
#          2.  The email address to notify.
#
#          3.  The email address to use as the sender.
#
####
#
# Steve
# --
#



use strict;
use warnings;

use CGI;
use Encode 'decode_utf8';
use Text::Markdown;
use POSIX qw(strftime);


#
#  The directory to store comments in
#
#  In this case ~/comments/
#
my $COMMENT = $ENV{ 'DOCUMENT_ROOT' } . "../comments/";

#my $COMMENT = (getpwuid $>)[7]  . "/comments";


#
#  The notification addresses - leave blank to disable
#
my $TO   = 'weblog@steve.org.uk';
my $FROM = 'weblog@steve.org.uk';


#
# Get the parameters from the request - decoding them because UTF-8
# is the way of the future.  Yeah, I laughed too.
#
my $cgi = new CGI();

my $name = $cgi->param('name') || undef;
$name = decode_utf8($name) if ($name);

my $mail = $cgi->param('mail') || undef;
$mail = decode_utf8($mail) if ($mail);

my $body = $cgi->param('body') || undef;
$body = decode_utf8($body) if ($body);

my $id = $cgi->param('id') || undef;
$id = decode_utf8($id) if ($id);

my $link = $cgi->param('link') || undef;
$link = decode_utf8($link) if ($link);

my $cap  = $cgi->param('robot') || undef;
my $ajax = $cgi->param('ajax')  || 0;


#
# Strip newlins
#
$link =~ s/[\r\n]//g if ($link);
$id   =~ s/[\r\n]//g if ($id);
$name =~ s/[\r\n]//g if ($name);
$mail =~ s/[\r\n]//g if ($mail);


#
#  If any are missing just redirect back to the blog homepage.
#
if ( !defined($name) ||
     !length($name) ||
     !defined($mail) ||
     !length($mail) ||
     !defined($body) ||
     !length($body) ||
     !defined($id) ||
     !length($id) )
{
    if ($ajax)
    {
        print "Content-type: text/html\n\n";
        print "Missing fields.\n";
    }
    else
    {
        print "Location: http://" . $ENV{ 'HTTP_HOST' } . "/\n\n";
    }
    exit;
}


#
#  Does the captcha value contain text?  If so spam.
#
if ( defined($cap) && length($cap) )
{
    if ($ajax)
    {
        print "Content-type: text/html\n\n";
        print "Missing fields.\n";
    }
    else
    {
        print "Location: http://" . $ENV{ 'HTTP_HOST' } . "/\n\n";
    }
    exit;
}


#
#  Convert the message to crude HTML.
#
$body =~ s/\n$/<br>\n/mg;

#
#  Otherwise save them away.
#
#
#  ID.
#
if ( $id =~ /^(.*)[\/\\](.*)$/ )
{
    $id = $2;
}


#
#  Show the header
#
print "Content-type: text/html\n\n";


#
# get the current time
#
my $timestr = strftime "%e-%B-%Y-%H:%M:%S", gmtime;


#
#  Is the body spam?
#
my $url = 0;
my $tmp = $body;
$tmp =~ s/[\r\n]//g;
while ( $tmp =~ /(.*)URL=(.*)/ )
{
    $url += 1;
    $tmp = $2;
}
$COMMENT .= "spam/" if ( $url >= 5 );


#
#  Open the file.
#
my $file = $COMMENT . "/" . $id . "." . $timestr;
$file =~ s/[ \t]//g;
open( FILE, ">:encoding(UTF-8)", $file );
print FILE "Name: $name\n";
print FILE "Mail: $mail\n";
print FILE "Link: $link\n" if ( defined($link) );
print FILE "User-Agent: $ENV{'HTTP_USER_AGENT'}\n";
print FILE "IP-Address: $ENV{'REMOTE_ADDR'}\n";
print FILE "\n";


#
# Process the body into markdown if that module is available.
#
my $html = $body;

my $test = "use Text::Markdown;";
## no critic (Eval)
eval($test);
## use critic

if ( !$@ )
{
    $html = Text::Markdown::markdown($body);
}

print FILE $html;
close(FILE);


#
#  Send a mail.
#
my $bcopy = $body;
$bcopy =~ s/[ \t\r\n]//g;

if ( length($TO) && length($FROM) && length($bcopy) )
{
    open( SENDMAIL, "|/usr/lib/sendmail -t -f $FROM" );
    print SENDMAIL "To: $TO\n";
    print SENDMAIL "From: $FROM\n";
    print SENDMAIL "Subject: New Comment [$id]\n";
    print SENDMAIL "\n\n";
    print SENDMAIL
      "\nYou've received a new comment on your blog at http://$ENV{'HTTP_HOST'} :\n\n";

    print SENDMAIL "IP " . $ENV{ 'REMOTE_ADDR' } . "\n\n";

    print SENDMAIL $body;
    close(SENDMAIL);
}

#
#  Now show the user the thanks message..
#
if ( $cgi->param("ajax") )
{
    print <<EOF;
<h3>Comment Submitted</h3>
<blockquote>
<p>Thanks for your comment, it will be made live when the queue is moderated next.</p>
</blockquote>

EOF
    exit;
}
else
{
    print <<EOF;
<html>
 <head>
  <title>Thanks For Your Comment</title>
 </head>
 <body>
  <h2>Thanks!</h2>
  <p>Your comment will be included the next time this blog is rebuilt.</p>
  <p><a href="http://$ENV{'HTTP_HOST'}/">Return to blog</a>.</p>
 </body>
</html>
EOF
}
