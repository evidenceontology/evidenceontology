# config
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:

# path vars
SRC = eco-edit.owl
TGT = eco.owl
OBO = eco.obo
IMPORTS = imports

# annotation vars
NOW = $(shell date +'%m:%d:%Y %H:%M')
NS = http://purl.obolibrary.org/obo/eco/
V = $(shell date +'%Y-%m-%d')

all: $(TGT) $(OBO) import gaf-eco-mapping-derived.txt sparql_test slims
release: all clean

# ----------------------------------------
# ROBOT
# ----------------------------------------

build:
	mkdir -p $@

build/robot.jar: | build
	curl -L -o build/robot.jar https://build.berkeleybop.org/job/robot/lastSuccessfulBuild/artifact/bin/robot.jar

ROBOT := java -jar build/robot.jar

# ----------------------------------------
# MAIN
# ----------------------------------------

$(TGT): $(SRC) | extract
	$(ROBOT) merge --input $< --input build/go_import.owl --input build/obi_import.owl --output $@
	 reason --reasoner elk --create-new-ontology false --annotate-inferred-axioms true --exclude-duplicate-axioms true \
	annotate --version-iri "$(NS)releases/$(V)/eco.owl" --annotation oboInOwl:date "$(NOW)"\

$(OBO): $(TGT)
	$(ROBOT) convert --input $< --format obo --output $@

# ----------------------------------------
# IMPORTS
# ----------------------------------------

build/obi_lower_terms.owl: eco-edit.owl | build/robot.jar build
	python $(IMPORTS)/get_obi_terms.py

build/go_lower_terms.owl: eco-edit.owl | build/robot.jar build
	python $(IMPORTS)/get_go_terms.py

# Force extract to get any new releases

build/obi_imports.owl: build/obi_lower_terms.txt | build/robot.jar build
	$(ROBOT) extract --input-iri http://purl.obolibrary.org/obo/obi.owl --method MIREOT --upper-terms $(IMPORTS)/obi_upper_terms.txt --lower-terms $< --output $@

build/go_imports.owl: build/go_lower_terms.txt | build/robot.jar build
	$(ROBOT) extract --input-iri http://purl.obolibrary.org/obo/go.owl --method MIREOT --upper-terms $(IMPORTS)/go_upper_terms.txt --lower-terms $< --output $@

.PHONY: extract
extract: build/go_imports.owl build/obi_imports.owl | build/robot.jar build

# ----------------------------------------
# SPARQL
# ----------------------------------------

# create derived GO mapping file
gaf-eco-mapping-derived.txt: $(TGT)
	$(ROBOT) query --input $(TGT) --format tsv --select sparql/derived.sparql build/$@ \
	&& sed 's/\"//g' build/$@\
	 | sed 's/\^\^<http:\/\/www\.w3\.org\/2001\/XMLSchema#string>//g'\
	 | tail -n +2 > $@

# run all violation checks (from ontology-starter-kit)
# requires 'reports' directory
VCHECKS = equivalent-classes trailing-whitespace owldef-self-reference xref-syntax nolabels
VQUERIES = $(foreach V,$(VCHECKS),sparql/$V-violation.sparql)

.PHONY: sparql_test
sparql_test: $(SRC) | build/robot.jar build
	$(ROBOT) verify -i $< --queries $(VQUERIES) -O build/

.PHONY: test
test: sparql_test clean

# ----------------------------------------
# SLIMS
# ----------------------------------------

SUB = subsets/
slims: go_groupings biological_process cellular_component chemical_entity gene molecular_function protein protein_complex

go_groupings: $(SUB)go_groupings.owl $(SUB)go_groupings.obo $(SUB)go_groupings.owx
$(SUB)go_groupings.owl: eco.owl
	owltools $< --extract-ontology-subset --subset go_groupings --iri $(NS)$@ -o $@
$(SUB)go_groupings.obo: $(SUB)go_groupings.owl
	$(ROBOT) convert --input $< --format obo --output $@
$(SUB)go_groupings.owx: $(SUB)go_groupings.owl
	$(ROBOT) convert --input $< --format owx --output $@

biological_process: $(SUB)valid_with_biological_process.owl $(SUB)valid_with_biological_process.obo $(SUB)valid_with_biological_process.owx
$(SUB)valid_with_biological_process.owl: eco.owl
	owltools $< --extract-ontology-subset --subset valid_with_biological_process --iri $(NS)$@ -o $@
$(SUB)valid_with_biological_process.obo: $(SUB)valid_with_biological_process.owl
	$(ROBOT) convert --input $< --format obo --output $@
$(SUB)valid_with_biological_process.owx: $(SUB)valid_with_biological_process.owl
	$(ROBOT) convert --input $< --format owx --output $@

cellular_component: $(SUB)valid_with_cellular_component.owl $(SUB)valid_with_cellular_component.obo $(SUB)valid_with_cellular_component.owx
$(SUB)valid_with_cellular_component.owl: eco.owl
	owltools $< --extract-ontology-subset --subset valid_with_cellular_component --iri $(NS)$@ -o $@
$(SUB)valid_with_cellular_component.obo: $(SUB)valid_with_cellular_component.owl
	$(ROBOT) convert --input $< --format obo --output $@
$(SUB)valid_with_cellular_component.owx: $(SUB)valid_with_cellular_component.owl
	$(ROBOT) convert --input $< --format owx --output $@

chemical_entity: $(SUB)valid_with_chemical_entity.owl $(SUB)valid_with_chemical_entity.obo $(SUB)valid_with_chemical_entity.owx
$(SUB)valid_with_chemical_entity.owl: eco.owl
	owltools $< --extract-ontology-subset --subset valid_with_chemical_entity --iri $(NS)$@ -o $@
$(SUB)valid_with_chemical_entity.obo: $(SUB)valid_with_chemical_entity.owl
	$(ROBOT) convert --input $< --format obo --output $@
$(SUB)valid_with_chemical_entity.owx: $(SUB)valid_with_chemical_entity.owl
	$(ROBOT) convert --input $< --format owx --output $@

gene: $(SUB)valid_with_gene.owl $(SUB)valid_with_gene.obo $(SUB)valid_with_gene.owx
$(SUB)valid_with_gene.owl: eco.owl
	owltools $< --extract-ontology-subset --subset valid_with_gene --iri $(NS)$@ -o $@
$(SUB)valid_with_gene.obo: $(SUB)valid_with_gene.owl
	$(ROBOT) convert --input $< --format obo --output $@
$(SUB)valid_with_gene.owx: $(SUB)valid_with_gene.owl
	$(ROBOT) convert --input $< --format owx --output $@

molecular_function: $(SUB)valid_with_molecular_function.owl $(SUB)valid_with_molecular_function.obo $(SUB)valid_with_molecular_function.owx
$(SUB)valid_with_molecular_function.owl: eco.owl
	owltools $< --extract-ontology-subset --subset valid_with_molecular_function --iri $(NS)$@ -o $@
$(SUB)valid_with_molecular_function.obo: $(SUB)valid_with_molecular_function.owl
	$(ROBOT) convert --input $< --format obo --output $@
$(SUB)valid_with_molecular_function.owx: $(SUB)valid_with_molecular_function.owl
	$(ROBOT) convert --input $< --format owx --output $@

protein: $(SUB)valid_with_protein.owl $(SUB)valid_with_protein.obo $(SUB)valid_with_protein.owx
$(SUB)valid_with_protein.owl: eco.owl
	owltools $< --extract-ontology-subset --subset valid_with_protein --iri $(NS)$@ -o $@
$(SUB)valid_with_protein.obo: $(SUB)valid_with_protein.owl
	$(ROBOT) convert --input $< --format obo --output $@
$(SUB)valid_with_protein.owx: $(SUB)valid_with_protein.owl
	$(ROBOT) convert --input $< --format owx --output $@

protein_complex: $(SUB)valid_with_protein_complex.owl $(SUB)valid_with_protein_complex.obo $(SUB)valid_with_protein_complex.owx
$(SUB)valid_with_protein_complex.owl: eco.owl
	owltools $< --extract-ontology-subset --subset valid_with_protein_complex --iri $(NS)$@ -o $@
$(SUB)valid_with_protein_complex.obo: $(SUB)valid_with_protein_complex.owl
	$(ROBOT) convert --input $< --format obo --output $@
$(SUB)valid_with_protein_complex.owx: $(SUB)valid_with_protein_complex.owl
	$(ROBOT) convert --input $< --format owx --output $@

# Clean up
clean: build
	rm -rf $<