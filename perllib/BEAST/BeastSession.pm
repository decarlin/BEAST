#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use DBI;

use Data::Dumper;
use BEAST::Set;
use BEAST::Constants;

package BeastSession;

sub saveMySets
{
	my $session = shift;
	my @sets = @_;

	my $mysetsstr;
	my $i = 0;
	foreach (@sets) {
		my $set = $_;
		if ($i == 0) {
			$mysetsstr = $set->serialize();
		} else {
			my $setstr = $set->serialize();
			$mysetsstr = $mysetsstr.":SEP:".$setstr;
		}
		$i++;
	}

	$session->param('mysets', $mysetsstr);
}

sub saveSearchResults
{
	my $session = shift;
	my @sets = @_;

	my $mysetsstr;
	my $i = 0;
	foreach (@sets) {
		my $set = $_;
		if ($i == 0) {
			$mysetsstr = $set->serialize();
		} else {
			my $setstr = $set->serialize();
			$mysetsstr = $mysetsstr.":SEP:".$setstr;
		}
		$i++;
	}

	$session->param('browseresults', $mysetsstr);
}

sub buildCheckedHash
{
	my @checked_sets = @_;

	my $hash = {};
	my $delim = Constants::SET_NAME_DELIM;
	foreach (@checked_sets) {
		my @parts = split(/$delim/, $_);
		$hash->{$parts[-1]} = 1;	
	}
	
	return $hash;
}

#
# Return: [ retval(0|1), @sets ]
#
sub loadSearchResults
{
	my $session = shift;
	my $cgi = shift;

	my $setsstr = $session->param('browseresults');	
	my @lines = split (/:SEP:/, $setsstr);

	my @sets;
	foreach (@lines) {
		push @sets, Set->new($_);
	}

	my @checked_sets = $cgi->param('browsesets[]');
	my $checked_hash = buildCheckedHash(@checked_sets);

	my @selected_sets;
	#  merge with checkbox data
	# fixme: we somehow have to only move the checked subset
	foreach (@sets) {
		my $set = $_;
		my $name = $set->get_name;
		if (exists $checked_hash->{$name}) {
			$set->mergeCheckbox_Remove($checked_hash);
			push @selected_sets, $set;
		}
	}

	return @selected_sets;
}
#
# Return: [ retval(0|1), @sets ]
#
sub loadMySets($)
{
	my $session = shift;

	my $setsstr = $session->param('mysets');	
	unless ($setsstr =~ /\S+/) { return 0; }
	my @lines = split (/:SEP:/, $setsstr);
	my @sets;
	foreach (@lines) {
		my $line = $_;
		next unless ($line =~ /_name/);
		push @sets, Set->new($line);
	}

	return @sets;
}

1;
