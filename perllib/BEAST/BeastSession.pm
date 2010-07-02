#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use DBI;

use Data::Dumper;
use BEAST::Set;
use BEAST::ImportSets;

package BeastSession;

sub saveMySets
{
	my $session = shift;
	my @sets = @_;

	my $mysetsstr;
	foreach (@sets) {
		my $set = $_;
		$mysetsstr = $mysetsstr.$set->serialize()."\n";
	}

	$session->param('mysets', $mysetsstr);
}

sub saveSearchResultSets
{
	my $session = shift;
	my @sets = @_;

	my $mysetsstr;
	foreach (@sets) {
		my $set = $_;
		$mysetsstr = $mysetsstr.$set->serialize()."\n";
	}

	$session->param('browseresults', $mysetsstr);
}

#
# Return: [ retval(0|1), @sets ]
#
sub loadSearchResults
{
	my $session = shift;
	my $setsref = shift;

	my $setsstr = $session->param('browseresults');	
	unless ($setsstr =~ /\n/) { return 0; }
	my @lines = split (/\n/, $setsstr);
	my @sets = ImportSets::parseSetLines(@lines);

	foreach (@sets) {
		push @{$setsref}, $_;
	}

	return 1;
}
#
# Return: [ retval(0|1), @sets ]
#
sub loadMySets
{
	my $session = shift;
	my $setsref = shift;

	my $setsstr = $session->param('mysets');	
	unless ($setsstr =~ /\n/) { return 0; }
	my @lines = split (/\n/, $setsstr);
	my @sets = ImportSets::parseSetLines(@lines);

	foreach (@sets) {
		push @{$setsref}, $_;
	}

	return 1;
}

1;
