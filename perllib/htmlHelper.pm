#!/usr/bin/perl -w
#Author:            Sam Boyarsky (xenicson@gmail.com)
#Create Date:       03.14.2008
#Location:          /projects/sysbio/www/cgi-bin/Sam/htmlHelper.pm

package htmlHelper;

use strict; 
use warnings;
use English;
use Pod::Usage;
use CGI qw(:standard);
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use BEAST::Constants;
use utils;

our @ISA		= qw(Exporter);
#our @EXPORT	= qw(printHeader printFooter $WEB_ROOT $WEB_CGI $WEB_STATIC $WEB_TEMP $PATH_CGI $PATH_STATIC $PATH_TEMP $TEMP_CHMOD );
#our @EXPORT	= qw(printHeader printFooter WEB_ROOT WEB_CGI WEB_STATIC WEB_TEMP PATH_CGI PATH_STATIC PATH_TEMP TEMP_CHMOD );
our @EXPORT		= qw(printHeader printFooter DEBUG beginSection beginTreeSection endSection);
our @EXPORT_OK	= qw();
our $VERSION	= 1.00;



use constant WEB_ROOT		=> 'http://sysbio.soe.ucsc.edu/beast/';
use constant COMMON_WEB_ROOT	=> 'http://sysbio.soe.ucsc.edu/common/';
#use constant WEB_CGI		=> 'scripts/';
use constant WEB_STATIC		=> '~samb';
use constant WEB_TEMP		=> 'samb/temp';
use constant PATH_CGI		=> '/cse/grads/samb/.html/metatrans';
use constant DEBUG			=> 0;

$OUTPUT_AUTOFLUSH = 1; # Flush standard output immediately.  (maybe could be written as $| or $AUTOFLUSH ???)
    
#sub printHeader($)
#{
#    my($title) = @_;
#    print header;   # is roughly equivilant to this line: print "Content-Type: text/html; charset=ISO-8859-1\n\n";
#    #print "<html xmlns='http://www.w3.org/1999/xhtml' lang='en-US' xml:lang='en-US'>\n";
#    print "<html>\n";
#    print "<head>\n";
#    print "<title>$title</title>\n";
#    print "<script type='text/javascript' src='".COMMON_WEB_ROOT."js/prototype.js?&ts=".time."'></script>\n";
#    print "<script type='text/javascript' src='".COMMON_WEB_ROOT."js/ajaxHelper.js?&ts=".time."'></script>\n";
#    print "<script type='text/javascript' src='".COMMON_WEB_ROOT."js/metatrans.js?&ts=".time."'></script>\n";
#    print "<link rel='stylesheet' type='text/css' href='".COMMON_WEB_ROOT."css/metatrans_style.css'/>";
#    print "</head>\n";
#    print "<form>\n";    #do we need to name the form or anything???????
#    
#}

sub printFooter()
{
    print "</form>\n";
    print "</body>\n";
    print "</html>\n";
}

sub beginTreeSection($$)
{
	my $name = shift;
	my $info_hash = shift;

	die unless (ref($info_hash) eq 'HASH');

	my $display = $info_hash->{'display'};
	my $checkedBool = $info_hash->{'checked'};
	my $desc = $info_hash->{'desc'} || "()";
	my $div_id = $info_hash->{'div_id'};
	my $db_id = $info_hash->{'db_id'};
	my $type = $info_hash->{'type'};

	my $fullName = $name;

	my $checkedText = "";
	if ($checkedBool == 1) {
		$checkedText = "checked";
	}
	## string to boolean conversion: can't pass bareword 'FALSE'/'TRUE' as argument
	if ($display eq 'FALSE') { 
		$display = 0;
	} else {
		$display = 1;
	}

	my $delim = Constants::SET_NAME_DELIM;
	my @nameComponents;
	my $marginleft = "margin-left:0px;";
	if (@nameComponents = split(/$delim/, $name)) {
		$name = $nameComponents[-1];
		$marginleft = "margin-left:".(($#nameComponents)*10)."px;";
	}

	# must be unique
	my $divID = $div_id.Constants::SET_NAME_DELIM.$name;	
	
	my $arrow = $display ? "images/ominus.png" : "images/plus.png";
	$display = $display ? "block":"none";
	print "<div id='$divID' style='$marginleft'>";
	if ($type eq 'meta') {
		print "<input style='$marginleft' type=checkbox onClick='updateMetaCheckBox(\"$divID\", this.checked)' name=\"$fullName\" value=\"$db_id\" $checkedText>";
		print "<span onClick=\"swapDivPlusMinus2('$divID\_content', '$divID\_arrow');\" class='expandable_header' >";
		print "<img id='$divID\_arrow' src='$arrow' height='10px' width='10px' />&nbsp;$name $desc";
		print "</span>";
		print "</div>\n";
		print "<div id='$divID\_content' style='display:$display'>\n";
	} elsif ($type eq 'set') {
		print "<input style='$marginleft' type=checkbox name=\"$fullName\" value=\"$db_id\" $checkedText>";
		my $ts = getTimestamp();
		my $depth = scalar(@nameComponents) + 3;
		print "<span onClick='onSetClick(\"$db_id\", $depth, \"$ts\")' class='expandable_header'><b>&nbsp;$name</b> $desc</span>";
		print "</div>\n";
		print "<div id='$db_id\_$ts\_content' style='display:$display'>\n";
	}

}
sub beginSection($$)
{
	my($section, $display) = @_;

	## string to boolean conversion: can't pass bareword 'FALSE'/'TRUE' as argument
	if ($display eq 'FALSE') { 
		$display = 0;
	} else {
		$display = 1;
	}

	my $arrow = $display ? "images/ominus.png" : "images/plus.png";
	$display = $display ? "block":"none";
	print "<div id='$section' onclick=\"swapDivPlusMinus2('$section\_content', '$section\_arrow');\" class='expandable_header'><h3><img id='$section\_arrow' src='$arrow' height='10px' width='10px'>&nbsp;$section </h3></div>\n";
	print "<div id='$section\_content' style='display:$display'>\n";

}

sub endSection($)
{
	my($section) = @_;
	print "</div> <!-- end $section -->\n";
}
