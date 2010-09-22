#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	8.27.2010

package Cluster;

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use lib "/var/www/cgi-bin/BEAST/perllib";

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
		$set->set_metadata_value('type', 'set_display');
		$lookup_hash->{$eisen_name} = $set;
		$count++;
	}
	$self->{'arry_to_set'} = $lookup_hash;

	bless $self, $class;
	return $self;
}

sub makeTabbedInputFile
{
	my $self = shift;
	my @sets = @{$self->{'sets'}};

	my $tempfile = "/tmp/".$self->{'session_id'}.".tab";

	open (TMP, ">$tempfile") || return 0;

	my @rows = Set::generateSetsUnion(@sets);

	foreach my $entity (@rows) {
		#print $entity;
		my $first_line = 0;
		foreach my $set (@sets) {
			if ($first_line > 0) {
				print TMP "\t";
			}
			$first_line++;
			print TMP $set->has_element($entity);
			#print "\t".$set->has_element($entity);
			#print "\t".Data::Dumper->Dump([$set->get_element($entity)]);
		}
		print TMP "\n";
		#print "<br>";
	}
	close TMP;

	#print `cat $tempfile`;
}

sub runCMD
{
	my $self = shift;

	my $cmd = Constants::CLUSTER_EISEN_64." -f /tmp/".$self->{'session_id'}.".tab -g 0 -e 2 2>/tmp/beast_cluster_err.log";
	print `$cmd`;

	my $outfile = "/tmp/".$self->{'session_id'}.".atr";

	if (! -f $outfile) {
		print `cat /tmp/beast_cluster_err.log`;
		unlink("/tmp/beast_cluster_err.log");
		return 0;
	}

	open (OUTPUT, $outfile) || return 0;
	my @lines = <OUTPUT>;
	close OUTPUT;
	$self->{'output'} = [ @lines ];

	return 1;
}

sub print_atr_output
{
	my $self = shift;
	
	foreach my $line (@{$self->{'output'}}) {
		print $line."<br>";
	}
}

sub get_clusters
{
	my $self = shift;

	my $nodes = {};

	my $arry_to_set = $self->{'arry_to_set'};

	foreach my $line (@{$self->{'output'}}) {

		chomp ($line);

		# not using the score
		my ($node, $arry1, $arry2, $score) = split (/\t/, $line);

		my ($node1, $node2);
		my ($nodename1, $nodename2);

		if (exists $arry_to_set->{$arry1}) {
			$node1 = $arry_to_set->{$arry1};
		} else {

			# if this node is under this subtree, it will never appear 
			# under another subtree: delete it from the hash
			$node1 = $nodes->{$arry1};
			delete $nodes->{$arry1};
			
		}

		return unless (ref($node1) eq 'Set');

		$nodename1 = $node1->get_name;

		if (exists $arry_to_set->{$arry2}) {
			$node2 = $arry_to_set->{$arry2};
		} else {

			# if this node is under this subtree, it will never appear 
			# under another subtree: delete it from the hash
			$node2 = $nodes->{$arry2};
			delete $nodes->{$arry2};

		}
		$nodename2 = $node2->get_name;

		# create a new heirarchy object
		my $new_node = Set->new($node, 1, {'type' => 'meta_display', 'name' => $score }, { $nodename1 => $node1, $nodename2 => $node2 });

		# remember this node
		$nodes->{$node} = $new_node;

	}


	my @clusters;
	foreach my $key (keys %$nodes) {
		push @clusters, $nodes->{$key};
	}

	return @clusters;
}

sub run
{
	my $self = shift;

	$self->makeTabbedInputFile;
	my $status = $self->runCMD;

	my $tempfile = "/tmp/".$self->{'session_id'}.".tab";
	my $output = "/tmp/".$self->{'session_id'}.".atr";
	my $cdt = "/tmp/".$self->{'session_id'}.".cdt";

	unlink($tempfile);
	unlink($output);
	unlink($cdt);

	return $status;
}

1;
