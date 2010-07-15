#!/usr/local/bin/perl

use lib "/projects/sysbio/map/Projects/BEAST/perllib";

use BEAST::BeastDB;

our $importer = BeastDB->new;
$importer->connectDB();

# GO:0090077	NULL	human:GO:0090077

# add the first parent to each of human:GO:xxxx and mouse:GO:xxxx
sub prependZeros
{
	my $num = shift;
	while (length($num) < 5) {
		$num = "0".$num;	
	}

	return $num;
}

my $str = "GO:00";
for my $counter (36 .. 90077) {

	my $key = $str.prependZeros($counter);
	# external meta id
	my $meta_external_id = $key;

	# external set id
	my $set_id_human = "human:".$key;	
	# external_set id
	my $set_id_mouse = "mouse:".$key;	


	# get the internal set id's
	my $int_id_set_human = $importer->getSetIdFromExternalId($set_id_human);
	my $int_id_set_mouse = $importer->getSetIdFromExternalId($set_id_mouse);

	# get the internal meta id's
	my $int_id_meta = $importer->getMetaIdFromExternalId($meta_external_id);

	unless ($int_id_meta =~ /\d+/) {
		print "No meta for external id: $meta_external_id, skipping...\n";
		next;
	}

	# create the relation for both
	print "Line: $counter of 90077\n";

	if ($int_id_set_human =~ /\d+/) {
		print "adding meta value:$int_id_meta for set:$int_id_set_human\n";
		$importer->insertMetaMetaRel($int_id_meta, $int_id_set_human, "NULL");;
	}
	if ($int_id_set_mouse =~ /\d+/) {
		print "adding meta value:$int_id_meta for set:$int_id_set_mouse\n";
		$importer->insertMetaMetaRel($int_id_meta, $int_id_set_mouse, "NULL");;
	}

}
$importer->disconnectDB();
