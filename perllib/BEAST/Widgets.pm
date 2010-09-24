#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	9.23.2010

package Widgets;

use strict;
use warnings;


###

sub printSelects
{
	# keys for first are the 
	my $dataRef = shift;


	my @top_nodes = keys %$dataRef;

	# write hidden page data so javascript can list the set of possible organisms, based 
	# on the currently selected option	
	foreach my $opt (@top_nodes) {
		my $value_str =  $dataRef->{$opt}->[0];
		foreach my $i (1 .. scalar(@{$dataRef->{$opt}}) - 1) {
			$value_str .= ",".$dataRef->{$opt}->[$i];

		}
		print "<input id=\"$opt\" type=\"hidden\" value='$value_str'/>\n";
	}

	print "<select onChange=\"onImportSourceChanged(this);\">";
	print "<option value=\"none\">none</option>\n";
	foreach my $opt (@top_nodes) {
		print "<option value=\"$opt\">$opt</option>\n";
	}
	print "</select>";

	print "<select id=\"importOrganism\">";
	print "<option value=\"none\">none</option>\n";
	# all disabled by default, until they select a source
	foreach my $opt (@top_nodes) {
		my @organisms =  @{$dataRef->{$opt}};
		foreach my $organism (@organisms) {
			print "<option value=\"$organism\" disabled=\"disabled\">$organism</option>\n";
		}
	}
	print "</select>";

}

1;
