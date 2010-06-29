#!/bin/bash

# Must be run from BEAST/tools directory

inputdir="$MAPDIR/shared"
outputdir="$MAPDIR/shared/processed"

for file in `cd $inputdir && ls *\.*`; do
	type="`echo $file | cut.pl -d '\.' -f -1`"
	echo "processing file:$inputdir/$file To $outputdir/$file.sql_commands"
	echo "perl ./sql_generate.pl --type=$type < $inputdir/$file > $outputdir/$file.sql_commands"
	perl ./sql_generate.pl --type=$type < $inputdir/$file > $outputdir/$file.sql_commands
done
