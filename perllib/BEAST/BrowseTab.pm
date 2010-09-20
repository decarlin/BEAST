#!/usr/bin/perl -w
#Author:	Sam Boyarsky (samb@soe.ucsc.edu)
#Create Date:	7.22.2010

package BrowseTab;

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use lib "/var/www/cgi-bin/BEAST/perllib";
use htmlHelper;
use BEAST::BeastDB;
use BEAST::Search;
use Data::Dumper;
use utils;

our $TRUE = 1;
our $FALSE = 0;

###
### Build the Search Tab
###

sub new
{
	my $class = shift;
	my $self = {
		_input 		=> shift,
	};

	bless $self, $class;
	return $self;
}

sub validateSearchResults
{
	my @results = @_;

	if ( $#results == -1 || (!ref($results[0]))) {
		print "<br>No Sets Found<br>";
		return 0;
	}

	return 1;
}

sub buildSearchOpts
{
	my $searchopts = shift;
	my $checkboxdata = shift;
}


sub printTab
{
	# hash ref to the input form data
	my $self = shift;
	my $session = shift || undef;
	my $ts = getTimestamp();	#time stamp for appending to HTML ids so that they remain unique
	
	if (defined $session)
	{
		die unless (ref($session) eq 'CGI::Session');
	}

	my $beastDB = BeastDB->new;
	$beastDB->connectDB();

#	my $roots = $beastDB->findRoots();
	my $roots = $beastDB->getRoots();
	
	print "<form id=\"browsecategories\">";
	print "<input type='button' value='Add To My Sets' onClick=\"return onAddBrowseSets(this.form);\"><br>";

	#For all the roots returned above, print the html to display them
	#automatically set the depth passed to the children to 1
	foreach my $root (keys %{$roots})
	{
		my $id = $roots->{$root}{'id'};
		my $name = $roots->{$root}{'name'};
		my $external_id = $roots->{$root}{'external_id'};
		#print checkbox for this div
#		print "<input style='margin-left:0px;' type='checkbox' name='browse' value='$id'/>";
		print "<div style='padding-top:3px;'><span onClick='toggleChildren(\"$id\", 1, \"$ts\")' class='expandable_header'><img id='$id\_$ts\_arrow' src='images/plus.png' height='10px' width='10px'>$external_id ($name)</span>";
		print "<div id='$id\_$ts\_children' style='display:none'></div></div>";
	}
	$beastDB->disconnectDB();

	print "</form>";
}

sub dig
{
	# hash ref to the input form data
	my $self = shift;
	my $session = shift || undef;
	my $ts = getTimestamp();	#time stamp for appending to HTML ids so that they remain unique
	
	if (defined $session) 
	{
		die unless (ref($session) eq 'CGI::Session');
	}
	
	my $input = $self->{'_input'};
	my $parent_id = $input->param('parent_id');
	
	my $depth = $input->param('depth');
	my $indent_depth = 10*$depth."px";
	my $child_depth = $depth+1;
	
	my $beastDB = BeastDB->new;
	$beastDB->connectDB();

	#for filtering
	#we could pass a filterlist that the SQL database knows how to respect.
	my $children = $beastDB->getChildren($parent_id);
	
	#print sets
	foreach my $child (sort keys %{$children->{'set'}})
	{
		my $id = $children->{'set'}{$child}{'id'};
		my $name = $children->{'set'}{$child}{'name'};
		my $external_id = $children->{'set'}{$child}{'external_id'};
		print "<div><input style='margin-left:$indent_depth;' type='checkbox' name='browse' value='$id'/>";
		#print "<span onClick='show_entities(\"$id\", $child_depth, \"$ts\")' class='expandable_header'><img id='$id\_$ts\_arrow' src='images/plus.png' height='10px' width='10px'>$external_id ($name)</span>";
		print "<span>$external_id ($name)</span>";
		print "<div id='$id\_$ts\_children' style='display:none'></div></div>";
	}

	#print metas
	foreach my $child (sort keys %{$children->{'meta'}})
	{
		my $id = $children->{'meta'}{$child}{'id'};
		my $name = $children->{'meta'}{$child}{'name'};
		my $external_id = $children->{'meta'}{$child}{'external_id'};
#		print "<input style='margin-left:$indent_depth;' type='checkbox' name='browse' value='$id'/>";
		print "<div style='padding-top:3px;'><span style='margin-left:$indent_depth;' onClick='toggleChildren(\"$id\", $child_depth, \"$ts\")' class='expandable_header'><img id='$id\_$ts\_arrow' src='images/plus.png' height='10px' width='10px'>$external_id ($name)</span>";
		print "<div id='$id\_$ts\_children' style='display:none'></div></div>";
	}
	
	$beastDB->disconnectDB();
}


1;
