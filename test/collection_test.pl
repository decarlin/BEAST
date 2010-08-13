#!/usr/local/bin/perl

use strict;

use lib "/projects/sysbio/map/Projects/BEAST/perllib";

use BEAST::Set;
use BEAST::Collection;

my $set2 = Set->new('{"_metadata":{"name":"kinesin-associated mitochondrial adaptor activity","id":"154128","type":"set"},"_name":"human:GO:0019895","_delim":"^","_active":1,"_elements":{"TRAK1":""}}');
my $set3 = Set->new('{"_metadata":{"name":"mitochondrial proton-transporting ATP synthase complex, catalytic core F(1)","id":"142716","type":"set"},"_name":"human:GO:0000275","_delim":"^","_active":1,"_elements":{"ATP5E":"","ATP5C1":"","ATP5B":"","ATP5D":""}}');


my @sets = ($set2, $set3);

my $collection1 = Collection->new('sets', @sets);
my $json = $collection1->serialize();
print $json."\n";
