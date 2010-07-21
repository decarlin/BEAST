
use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";

use BEAST::Set;

my @sets;

my $set1 = Set->new(
		'Bread', 
		1,
		{ 'type' => 'food' }, 
		{ 
			'Rye' => 1, 
			'Wheat' => 0, 
			'Sourdough' => 0 
		}
);
my $gmSet = Set->new(
		'GeneralMills', 
		1,
		{ 'type' => 'manuf' }, 
		{ 
			'Cheerios' 	=> 1, 
			'Trix'		=> 0,
			'Wheaties'	=> 1 
		}
);
my $set2 = Set->new(
		'Cereal', 
		0,
		{ 'type' => 'food' }, 
		{ 
			'RiceCrispies' => 1, 
			'CocoPuffs' => 1, 
			$gmSet->get_name => $gmSet,
		}
);

# two trees that share the same top level node, but different
# child nodes (as indicated by name)
my $tree1 = Set->new(
	'Food',
	1,
	{ 'type' => 'top_node' },
	{
		$set1->get_name => $set1	
	}
);

#
my $tree2 = Set->new(
	'Food',
	1,
	{ 'type' => 'top_node' },
	{
		$set2->get_name => $set2	
	}
);


## Tree Merge Test
print "Testing Tree-Merge Function...\n";

print "Before merge:\n";
print "Tree1: ".$tree1->serialize()."\n";
print "Tree2: ".$tree2->serialize()."\n";
$tree1->mergeTree($tree2);
print "After Merge: ".$tree1->serialize()."\n";
