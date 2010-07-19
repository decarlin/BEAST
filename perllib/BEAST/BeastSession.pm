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

sub saveSetsToSession
{
	my $session = shift;
	my $key = shift;
	my @sets = @_;

	die unless (ref($session) eq 'CGI::Session');
	die unless (ref($sets[0]) eq 'Set');

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

	$session->param($key, $mysetsstr);
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
sub loadMergeSetsFromSession($$$)
{
	my $session = shift;
	my $key = shift;
	my $checkbox_arr_ref = shift;

	die unless (ref($checkbox_arr_ref) eq 'ARRAY');
	die unless (ref($session) eq 'CGI::Session');
	die unless ($key =~ /^\w+$/);

	my $setsstr = $session->param($key);	
	my @lines = split (/:SEP:/, $setsstr);

	my @sets;
	foreach (@lines) {
		push @sets, Set->new($_);
	}

	my $checked_hash = buildCheckedHash(@$checkbox_arr_ref);
	my @selected_sets = mergeWithCheckbox(\@sets, $checked_hash);

	return @selected_sets;
}

sub mergeWithCheckbox
{
	my $sets_ref = shift;
	my $checked_hash = shift;

	die unless (ref($sets_ref) eq 'ARRAY');
	die unless (ref($checked_hash) eq 'HASH');

	my @selected_sets;
	#  merge with checkbox data
	# fixme: we somehow have to only move the checked subset
	my @sets = @$sets_ref;
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

sub loadSetsFromSession($$)
{
	my $session = shift;
	my $key = shift;

	die unless (ref($session) eq 'CGI::Session');
	die unless ($key =~ /^\w+$/);

	my $setsstr = $session->param($key);	
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
