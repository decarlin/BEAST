#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	8.27.2010

package Cluster;

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";

our $TRUE = 1;
our $FALSE = 0;

use Math::BigFloat;
use BEAST::Constants;

# Wrapper for sets_overlap.pl
# calls cluster-eisen

sub new
{
	my $class = shift;
	my $session_id = shift;
	my @sets = @_;

	my $self = { 'session_id' => $session_id,
		     'sets' => \@sets };

	my $lookup_hash = {};
	my $count = 0;
	foreach my $set (@sets) {
		my $eisen_name = "ARRY".$count."X";		
		$lookup_hash->{$eisen_name} = $set;
	}
	$self->{'arry_to_setname'} = $lookup_hash;

	bless $self, $class;
	return $self;
}

sub makeTabbedInputFile
{
	my $self = shift;
	my @sets = @{$self->{'sets'}};


	my $tempfile = "/tmp/".$self->{'session_id'}."tab";

	open (TMP, ">$tempfile") || return 0;

	my @rows = Set::generateSetsUnion(@sets);
	foreach my $entity (@rows) {
		#print $entity;
		foreach my $set (@sets) {
			print TMP "\t".$set->has_element($entity);
		}
		print "\n";
	}
	close TMP;
}

sub runCMD
{
	my $self = shift;

	my $cmd = Constants::JAVA_32_BIN." ".Constants::CLUSTER_EISEN." -f /tmp/".$self->{'session_id'}."tab -g 0 -e 2";
	`$cmd`;

	my $outfile = "/tmp/".$self->{'session_id'}."atr";

	open (OUTPUT, $outfile) || return 0;
	my @lines = <OUTPUT>;
	close OUTPUT;
	$self->{'output'} = [ @lines ];

	return 1;
}

sub get_cluster
{
	my $nodes = {};

	my $arry_to_set = $self->{'arry_to_set'};
	foreach my $line (@{$self->{'output'}}) {
		chomp ($line);
		my ($node, $arry1, $arry2, $score) = split (/\t/, $line);


		my ($node1, $node2);
		my ($nodename1, $nodename2);

		if (exists $arry_to_set->{$arry1}) {
			$node1 = $arry_to_set->{$arry1};
		} else {
			$node1 = $nodes->{$arry1};
		}
		$nodename1 = $node1->get_name;

		if (exists $arry_to_set->{$arry2}) {
			$node2 = $arry_to_set->{$arry2};
		} else {
			$node2 = $nodes->{$arry2};
		}
		$nodename2 = $node2->get_name;

		my ($set1name, $set2name) = ($set1->get_name, $set2->get_name);
		my $new_node = Set->new($node, 1, {'type' => 'meta_display'}, { $nodename1 => $node1, $nodename2 => $node2 });

	}
}

sub run
{
	my $self = shift;

	$self->makeTabbedInputFile;
	$self->runCMD;

	my $tempfile = "/tmp/".$self->{'session_id'}."tab";
	my $output = "/tmp/".$self->{'session_id'}."atr";

	unlink($tempfile);
	unlink($output);
}

1;
