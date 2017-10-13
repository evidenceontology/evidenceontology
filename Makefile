# path vars
SRC = eco-edit.owl
TGT = eco.owl
OBO = eco.obo

# annotation vars
NOW = $(shell date +'%m:%d:%Y %H:%M')
NS = http://purl.obolibrary.org/obo/eco/
V = $(shell date +'%Y-%m-%d')

all: $(TGT) $(OBO) gaf-eco-mapping-derived.txt sparql_test slims
release: all

# Main release from editor file
$(TGT): $(SRC)
	robot annotate --input $< --version-iri "$(NS)releases/$(V)/eco.owl" --annotation oboInOwl:date "$(NOW)"\
	 reason --reasoner elk --create-new-ontology false --annotate-inferred-axioms true --exclude-duplicate-axioms true --output $@

$(OBO): $(TGT)
	robot convert --input $< --format obo --output $@

# ----------------------------------------
# sparql
# ----------------------------------------

# create derived GO mapping file
gaf-eco-mapping-derived.txt: $(TGT)
	mkdir temp
	robot query --input $(TGT) --format tsv --select sparql/derived.sparql temp/$@ \
	&& sed 's/\"//g' temp/$@\
	 | sed 's/\^\^<http:\/\/www\.w3\.org\/2001\/XMLSchema#string>//g'\
	 | tail -n +2 > $@
	rm -rf temp

# run all violation checks (from ontology-starter-kit)
# requires 'reports' directory
VCHECKS = equivalent-classes trailing-whitespace owldef-self-reference xref-syntax nolabels
VQUERIES = $(foreach V,$(VCHECKS),sparql/$V-violation.sparql)
sparql_test: $(SRC)
	robot verify -i $< --queries $(VQUERIES) -O reports/

# ----------------------------------------
# SLIMS
# ----------------------------------------

SUB = subsets/
slims: go_groupings biological_process cellular_component chemical_entity gene molecular_function protein protein_complex

go_groupings: $(SUB)go_groupings.owl $(SUB)go_groupings.obo $(SUB)go_groupings.owx
$(SUB)go_groupings.owl: eco.owl
	owltools $< --extract-ontology-subset --subset go_groupings --iri $(NS)$@ -o $@
$(SUB)go_groupings.obo: $(SUB)go_groupings.owl
	robot convert --input $< --format obo --output $@
$(SUB)go_groupings.owx: $(SUB)go_groupings.owl
	robot convert --input $< --format owx --output $@

biological_process: $(SUB)valid_with_biological_process.owl $(SUB)valid_with_biological_process.obo $(SUB)valid_with_biological_process.owx
$(SUB)valid_with_biological_process.owl: eco.owl
	owltools $< --extract-ontology-subset --subset valid_with_biological_process --iri $(NS)$@ -o $@
$(SUB)valid_with_biological_process.obo: $(SUB)valid_with_biological_process.owl
	robot convert --input $< --format obo --output $@
$(SUB)valid_with_biological_process.owx: $(SUB)valid_with_biological_process.owl
	robot convert --input $< --format owx --output $@

cellular_component: $(SUB)valid_with_cellular_component.owl $(SUB)valid_with_cellular_component.obo $(SUB)valid_with_cellular_component.owx
$(SUB)valid_with_cellular_component.owl: eco.owl
	owltools $< --extract-ontology-subset --subset valid_with_cellular_component --iri $(NS)$@ -o $@
$(SUB)valid_with_cellular_component.obo: $(SUB)valid_with_cellular_component.owl
	robot convert --input $< --format obo --output $@
$(SUB)valid_with_cellular_component.owx: $(SUB)valid_with_cellular_component.owl
	robot convert --input $< --format owx --output $@

chemical_entity: $(SUB)valid_with_chemical_entity.owl $(SUB)valid_with_chemical_entity.obo $(SUB)valid_with_chemical_entity.owx
$(SUB)valid_with_chemical_entity.owl: eco.owl
	owltools $< --extract-ontology-subset --subset valid_with_chemical_entity --iri $(NS)$@ -o $@
$(SUB)valid_with_chemical_entity.obo: $(SUB)valid_with_chemical_entity.owl
	robot convert --input $< --format obo --output $@
$(SUB)valid_with_chemical_entity.owx: $(SUB)valid_with_chemical_entity.owl
	robot convert --input $< --format owx --output $@

gene: $(SUB)valid_with_gene.owl $(SUB)valid_with_gene.obo $(SUB)valid_with_gene.owx
$(SUB)valid_with_gene.owl: eco.owl
	owltools $< --extract-ontology-subset --subset valid_with_gene --iri $(NS)$@ -o $@
$(SUB)valid_with_gene.obo: $(SUB)valid_with_gene.owl
	robot convert --input $< --format obo --output $@
$(SUB)valid_with_gene.owx: $(SUB)valid_with_gene.owl
	robot convert --input $< --format owx --output $@

molecular_function: $(SUB)valid_with_molecular_function.owl $(SUB)valid_with_molecular_function.obo $(SUB)valid_with_molecular_function.owx
$(SUB)valid_with_molecular_function.owl: eco.owl
	owltools $< --extract-ontology-subset --subset valid_with_molecular_function --iri $(NS)$@ -o $@
$(SUB)valid_with_molecular_function.obo: $(SUB)valid_with_molecular_function.owl
	robot convert --input $< --format obo --output $@
$(SUB)valid_with_molecular_function.owx: $(SUB)valid_with_molecular_function.owl
	robot convert --input $< --format owx --output $@

protein: $(SUB)valid_with_protein.owl $(SUB)valid_with_protein.obo $(SUB)valid_with_protein.owx
$(SUB)valid_with_protein.owl: eco.owl
	owltools $< --extract-ontology-subset --subset valid_with_protein --iri $(NS)$@ -o $@
$(SUB)valid_with_protein.obo: $(SUB)valid_with_protein.owl
	robot convert --input $< --format obo --output $@
$(SUB)valid_with_protein.owx: $(SUB)valid_with_protein.owl
	robot convert --input $< --format owx --output $@

protein_complex: $(SUB)valid_with_protein_complex.owl $(SUB)valid_with_protein_complex.obo $(SUB)valid_with_protein_complex.owx
$(SUB)valid_with_protein_complex.owl: eco.owl
	owltools $< --extract-ontology-subset --subset valid_with_protein_complex --iri $(NS)$@ -o $@
$(SUB)valid_with_protein_complex.obo: $(SUB)valid_with_protein_complex.owl
	robot convert --input $< --format obo --output $@
$(SUB)valid_with_protein_complex.owx: $(SUB)valid_with_protein_complex.owl
	robot convert --input $< --format owx --output $@