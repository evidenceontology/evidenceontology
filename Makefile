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

all: pre build post
release: all

# ----------------------------------------
# ROBOT
# ----------------------------------------

mk: 
	mkdir -p build

build/robot.jar: | mk
	curl -L -o build/robot.jar https://build.berkeleybop.org/job/robot/lastSuccessfulBuild/artifact/bin/robot.jar

ROBOT := java -jar build/robot.jar

# ----------------------------------------
# MAIN
# ----------------------------------------

build: $(TGT) $(OBO)

$(TGT): $(SRC)
	$(ROBOT) merge --input $< --input build/go_imports.owl --input build/obi_imports.owl --output $@ \
	reason --reasoner elk --create-new-ontology false --annotate-inferred-axioms true --exclude-duplicate-axioms true \
	annotate --version-iri "$(NS)releases/$(V)/eco.owl" --annotation oboInOwl:date "$(NOW)"\

$(OBO): $(TGT)
	$(ROBOT) convert --input $< --format obo --output $@

# ----------------------------------------
# PRE-BUILD
# ----------------------------------------

pre: verify extract

# run all violation checks (from ontology-starter-kit)
# requires 'reports' directory
VCHECKS = equivalent-classes trailing-whitespace owldef-self-reference xref-syntax nolabels
VQUERIES = $(foreach V,$(VCHECKS),sparql/$V-violation.sparql)

# extract term IDs for imports
# first step, ensure we grab ROBOT
.PHONY: verify
verify: $(SRC) | build/robot.jar
	$(ROBOT) verify -i $< --queries $(VQUERIES) -O build/

.PHONY: obi_lower_terms
obi_lower_terms: eco-edit.owl
	python $(IMPORTS)/get_obi_terms.py

.PHONY: go_lower_terms
go_lower_terms: eco-edit.owl
	python $(IMPORTS)/get_go_terms.py

# extract from IRI
build/obi_imports.owl: obi_lower_terms
	$(ROBOT) extract --input-iri http://purl.obolibrary.org/obo/obi.owl --method MIREOT --upper-terms $(IMPORTS)/obi_upper_terms.txt --lower-terms build/$<.txt --output $@

build/go_imports.owl: go_lower_terms
	$(ROBOT) extract --input-iri http://purl.obolibrary.org/obo/go.owl --method MIREOT --upper-terms $(IMPORTS)/go_upper_terms.txt --lower-terms build/$<.txt --output $@

.PHONY: extract
extract: build/go_imports.owl build/obi_imports.owl

# ----------------------------------------
# POST-BUILD
# ----------------------------------------

post: gaf-eco-mapping-derived.txt slims clean

# create derived GO mapping file
gaf-eco-mapping-derived.txt: $(TGT)
	$(ROBOT) query --input $(TGT) --format tsv --select sparql/derived.sparql build/$@ \
	&& sed 's/\"//g' build/$@\
	 | sed 's/\^\^<http:\/\/www\.w3\.org\/2001\/XMLSchema#string>//g'\
	 | tail -n +2 > $@

# extract subsets
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