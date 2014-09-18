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
use POSIX qw(strftime);



#
#  The directory to store comments in.
#
# NOTE:  This should be writeable to the www-data user, and shouldn't
#        be inside your web-root - or you open up security hole.
#
# my $COMMENT = "/home/www/comments/";
#
my $COMMENT = $ENV{ 'DOCUMENT_ROOT' } . "../comments/";

#
#  The notification addresses - leave blank to disable
#
my $TO   = 'weblog@steve.org.uk';
my $FROM = 'weblog@steve.org.uk';


#
#  Use textile?
#
my $TEXTILE = 1;


#
#  Find sendmail
#
my $SENDMAIL = undef;
foreach my $file (qw ! /usr/lib/sendmail /usr/sbin/sendmail !)
{
    $SENDMAIL = $file if ( -x $file );
}


#
#  Get the parameters from the request.
#
my $cgi = new CGI();

my $name = $cgi->param('name')    || undef;
my $mail = $cgi->param('mail')    || undef;
my $body = $cgi->param('body')    || undef;
my $id   = $cgi->param('id')      || undef;
my $cap  = $cgi->param('captcha') || undef;
my $link = $cgi->param('link')    || undef;
my $ajax = $cgi->param("ajax")    || 0;


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
        print "<p>Some of the files were empty; please try again.\n";
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
#  Convert the message to HTML if textile is in use
#
if ($TEXTILE)
{

    #
    #  If we can load the module
    #
    my $test = "use Text::Textile;";
    eval($test);

    #
    #  There were no errors
    #
    if ( !$@ )
    {

        #
        #  Convert
        #
        my $textile = new Text::Textile;
        $body = $textile->process($body);
    }
}

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
#  Open the file.
#
my $file = $COMMENT . "/" . $id . "." . $timestr;
$file =~ s/[^a-z0-9\/]/_/gi;

open( FILE, ">", $file );
print FILE "Name: $name\n";
print FILE "Mail: $mail\n";
print FILE "User-Agent: $ENV{'HTTP_USER_AGENT'}\n";
print FILE "IP-Address: $ENV{'REMOTE_ADDR'}\n";
print FILE "Link: $link\n" if ($link);
print FILE "\n";
print FILE $body;
close(FILE);


#
#  Send a mail.
#
if ( length($TO) && length($FROM) && defined($SENDMAIL) )
{
    open( SENDMAIL, "|$SENDMAIL -t -f $FROM" );
    print SENDMAIL "To: $TO\n";
    print SENDMAIL "From: $FROM\n";
    print SENDMAIL "Subject: New Comment [$id]\n";
    print SENDMAIL "\n\n";
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
