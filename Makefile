# config
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:

ECO = eco
EDIT = src/ontology/eco-edit.owl
OBO = http://purl.obolibrary.org/obo/
# folders
BUILD = build/
SUB = subsets/
SPARQL = src/sparql/

.PHONY: update
update: modules imports
all: report build mapping subsets
release: all

# test is used for Travis integration
test: report verify
full-test: reason test

# ----------------------------------------
# ROBOT
# ----------------------------------------

init:
	mkdir -p $(BUILD)

$(BUILD)robot.jar: init
	curl -L -o $@ https://github.com/ontodev/robot/releases/download/v1.5.0/robot.jar

ROBOT := java -jar $(BUILD)robot.jar

# ----------------------------------------
# MODULES
# ----------------------------------------

TEMP = src/ontology/templates/
MOD = src/ontology/modules/

modules: $(MOD)obi_logic.owl

$(MOD)obi_logic.owl: $(TEMP)obi_logic.csv | $(BUILD)robot.jar
	$(ROBOT) merge --input-iri http://purl.obolibrary.org/obo/obi.owl\
	 --input-iri http://purl.obolibrary.org/obo/go.owl\
	 template --template $<\
	 annotate --ontology-iri "$(OBO)$(ECO)/modules/obi_logic.owl" --output $@

# ----------------------------------------
# IMPORTS
# ----------------------------------------

# Both GO and OBI are used in the OBI logic template
IMP = src/ontology/imports/
IMPS = go obi

imports: $(IMPS)

$(IMPS): $(MOD)obi_logic.owl | $(BUILD)robot.jar
	python $(IMP)get_terms.py $@
	robot extract --input-iri "$(OBO)$@.owl" \
	 --method bot --term-file $(IMP)$@_terms.txt \
	 --term-file $(IMP)etc_terms.txt --individuals exclude \
	remove --select "complement" --select "annotation-properties" \
	 --term-file $(IMP)annotations.txt \
	annotate --ontology-iri "$(OBO)eco/imports/$@_import.owl" \
	 --output $(IMP)$@_import.owl

# ----------------------------------------
# TESTS
# ----------------------------------------

# A report is written to build/reports/report.tsv

report: $(BUILD)report.tsv
.PHONY: $(BUILD)report.tsv
$(BUILD)report.tsv: $(EDIT) | $(BUILD)robot.jar
	$(ROBOT) report --input $<\
	 --output $@ --format tsv

# verify is part of 'test' for Travis

V_QUERIES := $(wildcard $(SPARQL)verify-*.rq)
.PHONY: verify
verify: | $(BUILD)robot.jar
	$(ROBOT) verify --input $(EDIT)\
	 --queries $(V_QUERIES) --output-dir $(BUILD)

reason: $(EDIT) | $(BUILD)robot.jar
	$(ROBOT) merge --input $< \
	reason \
	 --reasoner hermit \
	 --dump-unsatisfiable $(BUILD)unsatisfiable.owl

# ----------------------------------------
# MAIN
# ----------------------------------------

# eco-base.owl is an import-removed, *non-reasoned* release
BASE = $(ECO)-base
# eco-basic.owl is an import-removed, *reasoned* release
# with no equivalents and no anonymous parents
BASIC = $(ECO)-basic

build: $(ECO).owl $(ECO).obo $(BASE).owl $(BASIC).owl $(BASIC).obo

# release vars
TS = $(shell date +'%d:%m:%Y %H:%M')
DATE = $(shell date +'%Y-%m-%d')

$(ECO).owl: $(EDIT) | $(BUILD)robot.jar
	$(ROBOT) merge --input $< --collapse-import-closure true \
	 reason --reasoner hermit --create-new-ontology false \
	 --annotate-inferred-axioms true --exclude-duplicate-axioms true \
	 reduce annotate --version-iri "$(OBO)eco/releases/$(DATE)/eco.owl" \
	 --annotation oboInOwl:date "$(TS)" --output $@

$(ECO).obo: $(EDIT) | $(BUILD)robot.jar
	$(ROBOT) reason --input $< --reasoner elk --create-new-ontology false\
	 --annotate-inferred-axioms true --exclude-duplicate-axioms true \
	remove --select imports \
	reduce annotate --version-iri "$(OBO)eco/releases/$(DATE)/eco.owl" \
	 --annotation oboInOwl:date "$(TS)" \
	convert --format obo --check false --output $(basename $@)-temp.obo && \
	grep -v ^owl-axioms $(basename $@)-temp.obo > $@ && \
	rm $(basename $@)-temp.obo

$(BASE).owl: $(EDIT) | $(BUILD)robot.jar
	$(ROBOT) remove --input $< --select imports \
	annotate --ontology-iri "$(OBO)eco/$@"\
	 --version-iri "$(OBO)eco/releases/$(DATE)/$@"\
	 --annotation oboInOwl:date "$(TS)" --output $@

$(BASIC).owl: $(EDIT) | $(BUILD)robot.jar
	$(ROBOT) remove --input $< --select imports --trim true \
	reason --reasoner elk --annotate-inferred-axioms false reduce \
	remove --select "equivalents parents" --select "anonymous" \
	reduce annotate --ontology-iri "$(OBO)eco/$@"\
	 --version-iri "$(OBO)eco/releases/$(DATE)/$@"\
	 --annotation oboInOwl:date "$(TS)" --output $@

$(BASIC).obo: $(BASIC).owl | $(BUILD)robot.jar
	$(ROBOT) convert --input $< --format obo --check false\
	 --output $(basename $@)-temp.obo && \
	grep -v ^owl-axioms $(basename $@)-temp.obo > $@ && \
	rm $(basename $@)-temp.obo

# ----------------------------------------
# MAPPINGS
# ----------------------------------------

mapping: gaf-eco-mapping-derived.txt

# create derived GO mapping file
$(BUILD)gaf-eco-mapping-derived.txt: $(ECO).owl | $(BUILD)robot.jar
	$(ROBOT) query --input $(ECO).owl --format tsv\
	 --select $(SPARQL)make-derived-mapping.rq $@
	sed 's/\"//g' $@ | sed 's/\^\^<http:\/\/www\.w3\.org\/2001\/XMLSchema#string>//g' | tail -n +2 > $@.tmp 
	mv $@.tmp $@

# append mappings to header
gaf-eco-mapping-derived.txt: src/util/derived-header.txt build/gaf-eco-mapping-derived.txt
	cat $^ > $@

# ----------------------------------------
# SUBSETS
# ----------------------------------------

SUBS = go_groupings \
valid_with_biological_process \
valid_with_cellular_component \
valid_with_chemical_entity \
valid_with_gene \
valid_with_molecular_function \
valid_with_protein \
valid_with_protein_complex

subsets: $(SUBS)

# grab the annotation properties
$(BUILD)eco-annotation-properties.owl: $(ECO).owl | $(BUILD)robot.jar
	$(ROBOT) filter --input $<\
	 --select "annotation-properties annotations"\
	 --output $@

$(SUBS): $(ECO).owl $(BUILD)eco-annotation-properties.owl | $(BUILD)robot.jar
	$(ROBOT) filter --input $< \
	 --select "oboInOwl:inSubset=<http://purl.obolibrary.org/obo/eco#$@> annotations" \
	 merge --input $(word 2,$^) \
	 annotate --version-iri "http://purl.obolibrary.org/obo/eco/$(DATE)/subsets/$@.owl"\
	 --ontology-iri "http://purl.obolibrary.org/obo/eco/subsets/$@.owl"\
	 --output $(addprefix $(SUB), $(addsuffix .owl, $@))\
	 && $(ROBOT) convert --input $(addprefix $(SUB), $(addsuffix .owl, $@))\
	 --output $(addprefix $(SUB), $(addsuffix .obo, $@)) --check false\
	 && $(ROBOT) convert --input $(addprefix $(SUB), $(addsuffix .owl, $@))\
	 --output $(addprefix $(SUB), $(addsuffix .owx, $@))
