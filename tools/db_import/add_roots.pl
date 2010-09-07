
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use strict;

sub usage 
{
	my $msg = shift;
	print <<EOF;
##
## Usage:  perl $0 --metas_file=file --root_meta=internal_id
##
EOF
	print $msg."\n";	
}

use Getopt::Long;
use BEAST::BeastDB;

my $root_meta;
my @values;

my $metas_file;
GetOptions(
	"metas_file=s" => \$metas_file,
	"root_meta=s" => \$root_meta);

die &usage() unless ($root_meta =~ /\d+/);
die &usage() unless (-f $metas_file);
open (MET, $metas_file) || die;
@values = <MET>;
close MET;



my $importer = BeastDB->new('dev');
$importer->connectDB();

for my $value (@values) {

	chomp $value;

	my $meta_id = $importer->getMetaIdFromExternalId($value);	

	if ($meta_id =~ /\d\d+/) {
		print "adding $value : $meta_id to root meta $root_meta\n";
		$importer->insertSQL("insert into meta_sets (sets_meta_id, meta_meta_id) values ('".$root_meta."', '".$meta_id."');");
	}
}

$importer->disconnectDB();
