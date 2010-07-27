#!/usr/bin/perl -w
#Author:            Sam Boyarsky (xenicson@gmail.com)
#Create Date:       07/26/2010
#Last Edit Date:    07/26/2010

package DebugHelper;

use strict;
use warnings;
use English;

our @ISA        = qw(Exporter);
our @EXPORT     = qw( printRequestParameters );
our @EXPORT_OK  = qw();
our $VERSION    = 1.0;

use constant DEBUG => 1;


sub printRequestParameters($)
{
	my ($cgi) = @_;
	if(DEBUG)
	{
		print "<table><tr><th colspan=2>CGI Parameters</th></tr><tr><th>name</th><th>value</th></tr>";
		my @names = $cgi->param;
		foreach my $name (@names)
		{
			print "<tr><td>$name</td><td>".$cgi->param($name)."</td></tr>\n";
		}
		print "</table>";
	}
}
   
return 1;