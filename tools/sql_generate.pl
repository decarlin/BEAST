#!/usr/local/bin/perl


##
## Usage:  perl sql_generate.pl --type=meta|meta_sets... < fileinput.txt > sqlstatement.txt
##


use Getopt::Long;
our $type;
my $result = GetOptions("type=s" => \$type);


our $tables = {
	'meta' 		=> "INSERT INTO meta ('id', 'name') VALUES ('var1', 'var2');",
	# sets_meta_id = parent, sets_id = child if set, meta_meta_id = child if meta
	'meta_sets' 	=> "INSERT INTO meta_sets ('sets_meta_id', 'sets_id', 'meta_meta_id') VALUES ('var1', 'var2', 'var3');",
	'entity' 	=> "INSERT INTO entity ('id', 'name','description' , 'entity_key', 'keyspace_id') VALUES ('var1', 'var2', 'var3', 'var4', 'var5');",
	'set_entity' 	=> "INSERT INTO set_entity ('sets_id', 'entity_id', 'member_value') VALUES ('var1', 'var2', 'var3');",
	'sets'		=> "INSERT INTO sets ('id', 'name') VALUES ('var1', 'var2');",
	'keyspace'	=> "INSERT INTO keyspace ('id', 'organism', 'source', 'version', 'description', 'created', 'last_modified' ) VALUES ('var1', 'var2', 'var3', 'var4', 'var5');",
};

sub buildSQL
{
	my $line = shift;

	my @values = split(/\t/, $line);

	my $template = $tables->{$type};
	my $i = 1;
	foreach (@values) {
		my $value = $_;
		chomp($value);
		my $substr = "var".$i;

		if ($value eq "NULL") {
			$value = "";
		}

		$template =~ s/$substr/$value/;	
		$i++;
	}

	return $template;
}

while (<>) {
	my $sql = buildSQL($_);
	print $sql."\n";
}
