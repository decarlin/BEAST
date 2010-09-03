import sys
import pickle

lines = sys.stdin.readlines()

drugs = {}

for line in lines[1:]:
	parts = line.split('\t')

	name = parts[0]
	gene_key = parts[1]
	desc = parts[3].rstrip()
	gene_name = parts[2]

	if name in drugs:
		drugs[name]['genes'].append(gene_key)
	else:
		drugs[name] = {'desc':desc, 'genes':[gene_key]}





for name in drugs.keys():
	drug = drugs[name]

	set_str = drug['desc']+"^ex_id="+name+"^source=drugbank^keyspace=1"
	for gene in drug['genes']:
		set_str += '\t'+gene
	print set_str
