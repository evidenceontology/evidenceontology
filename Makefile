# config
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:

ONT = src/ontology
OBO = http://purl.obolibrary.org/obo
EDIT = src/ontology/eco-edit.owl

release: report main mapping subsets build/missing-go-codes.tsv
update: modules imports

test: report verify
full-test: reason test


# ----------------------------------------
# ROBOT
# ----------------------------------------

build:
	mkdir -p $@

build/robot.jar: | build
	curl -L -o $@ https://github.com/ontodev/robot/releases/download/v1.8.3/robot.jar

build/go.owl: | build
	curl -Lk http://purl.obolibrary.org/obo/go.owl > $@

build/obi.owl: | build
	curl -Lk http://purl.obolibrary.org/obo/obi.owl > $@

ROBOT := java -jar build/robot.jar


# ----------------------------------------
# MODULES
# ----------------------------------------

modules: $(ONT)/modules/obi_logic.owl

$(ONT)/modules/obi_logic.owl: build/obi.owl build/go.owl $(ONT)/templates/obi_logic.csv
	$(ROBOT) merge --input $< \
	--input $(word 2,$^) \
	template \
	--template $(word 3,$^) \
	annotate \
	--ontology-iri "$(OBO)/eco/modules/obi_logic.owl" \
	--output $@


# ----------------------------------------
# IMPORTS
# ----------------------------------------

# Both GO and OBI are used in the OBI logic template
imports: $(ONT)/imports/go_import.owl $(ONT)/imports/obi_import.owl

$(ONT)/imports/%_terms.txt: $(ONT)/imports/get_terms.py $(ONT)/modules/obi_logic.owl
	$(eval NS := $(word 1,$(subst _, ,$(notdir $@))))
	python $^ $(NS) $@

$(ONT)/imports/%_import.owl: build/%.owl $(ONT)/imports/%_terms.txt $(ONT)/imports/etc_terms.txt $(ONT)/imports/annotations.txt | build/robot.jar
	$(ROBOT) extract \
	 --input $< \
	 --method BOT \
	 --term-file $(word 2,$^) \
	 --term-file $(word 3,$^) \
	 --individuals exclude \
	remove \
	 --select "complement" \
	 --select "annotation-properties" \
	 --term-file $(word 4,$^) \
	annotate \
	 --ontology-iri "$(OBO)/eco/imports/$(notdir $@)" \
	 --output $@


# ----------------------------------------
# TESTS
# ----------------------------------------

# A report is written to build/reports/report.tsv

report: build/report.tsv
.PHONY: build/report.tsv
build/report.tsv: $(EDIT) | build/robot.jar
	$(ROBOT) report --input $< \
	 --output $@ --format tsv

# run reasoner & dump unsat module on any problem

build/eco-reasoned.owl: $(EDIT) | build/robot.jar
	$(ROBOT) merge --input $< \
	reason \
	 --reasoner hermit \
	 --dump-unsatisfiable build/unsatisfiable.owl \
	 --output $@

# verify is part of 'test' for Travis

V_QUERIES := $(wildcard src/sparql/verify-*.rq)
.PHONY: verify
verify: build/eco-reasoned.owl | build/robot.jar
	$(ROBOT) verify --input $< \
	 --queries $(V_QUERIES) \
	 --output-dir build/

# a report of any "used in manual assertion" terms that do not have a GO evidence code

build/missing-go-codes.tsv: build/eco-reasoned.owl src/sparql/get-missing-go-codes.rq | build/robot.jar
	$(ROBOT) query --input $< --query $(word 2,$^) $@


# ----------------------------------------
# MAIN
# ----------------------------------------

# eco-base.owl is an import-removed, *non-reasoned* release
BASE = eco-base
# eco-basic.owl is an import-removed, *reasoned* release
# with no equivalents and no anonymous parents
BASIC = eco-basic

main: eco.owl eco.obo $(BASE).owl $(BASIC).owl $(BASIC).obo

# release vars
TS = $(shell date +'%d:%m:%Y %H:%M')
DATE = $(shell date +'%Y-%m-%d')

eco.owl: $(EDIT)
	$(ROBOT) merge \
	 --input $< \
	 --collapse-import-closure true \
	reason \
	 --reasoner hermit \
	 --create-new-ontology false \
	 --annotate-inferred-axioms true \
	 --exclude-duplicate-axioms true \
	reduce \
	annotate \
	 --version-iri "$(OBO)/eco/releases/$(DATE)/eco.owl" \
	 --annotation oboInOwl:date "$(TS)" \
	 --output $@

eco.obo: $(EDIT) | build/robot.jar
	$(ROBOT) remove \
	 --input $< \
	 --select imports \
	reason \
	 --reasoner elk \
	 --create-new-ontology false \
	 --annotate-inferred-axioms true \
	 --exclude-duplicate-axioms true \
	reduce \
	annotate \
	 --version-iri "$(OBO)/eco/releases/$(DATE)/eco.owl" \
	 --annotation oboInOwl:date "$(TS)" \
	convert \
	 --format obo \
	 --check false \
	 --output $(basename $@)-temp.obo
	grep -v ^owl-axioms $(basename $@)-temp.obo > $@
	rm $(basename $@)-temp.obo

$(BASE).owl: $(EDIT) | build/robot.jar
	$(ROBOT) remove \
	 --input $< \
	 --select imports \
	annotate \
	 --ontology-iri "$(OBO)/eco/$@" \
	 --version-iri "$(OBO)/eco/releases/$(DATE)/$@" \
	 --annotation oboInOwl:date "$(TS)" \
	 --output $@

$(BASIC).owl: $(EDIT) | build/robot.jar
	$(ROBOT) remove \
	 --input $< \
	 --select imports \
	 --trim true \
	reason \
	 --reasoner elk \
	 --annotate-inferred-axioms false \
	reduce \
	remove \
	 --select "equivalents parents" \
	 --select "anonymous" \
	reduce \
	annotate \
	 --ontology-iri "$(OBO)/eco/$@" \
	 --version-iri "$(OBO)/eco/releases/$(DATE)/$@" \
	 --annotation oboInOwl:date "$(TS)" \
	 --output $@

$(BASIC).obo: $(BASIC).owl | build/robot.jar
	$(ROBOT) convert \
	 --input $< \
	 --format obo \
	 --check false \
	 --output $(basename $@)-temp.obo
	grep -v ^owl-axioms $(basename $@)-temp.obo > $@
	rm $(basename $@)-temp.obo


# ----------------------------------------
# MAPPINGS
# ----------------------------------------

.PHONY: mapping
mapping: gaf-eco-mapping-derived.txt

# create derived GO mapping file
build/gaf-eco-mapping-derived.txt: eco.owl src/sparql/make-derived-mapping.rq | build/robot.jar
	$(ROBOT) query \
	 --input eco.owl \
	 --format tsv \
	 --select $(word 2,$^) $@
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

subsets: $(foreach S,$(SUBS),subsets/$(S).owl) \
$(foreach S,$(SUBS),subsets/$(S).owx) \
$(foreach S,$(SUBS),subsets/$(S).obo)

# grab the annotation properties
build/eco-annotation-properties.owl: eco.owl | build/robot.jar
	$(ROBOT) filter --input $<\
	 --select "annotation-properties annotations"\
	 --output $@

subsets/%.owl: eco.owl $(BUILD)/eco-annotation-properties.owl | $(BUILD)/robot.jar
	$(ROBOT) filter --input $< \
	 --select "oboInOwl:inSubset=<http://purl.obolibrary.org/obo/eco#$@> annotations" \
	 merge --input $(word 2,$^) \
	 annotate --version-iri "http://purl.obolibrary.org/obo/eco/$(DATE)/subsets/$@.owl"\
	 --ontology-iri "http://purl.obolibrary.org/obo/eco/subsets/$@.owl"\
	 --output $@

subsets/%.obo: subsets/%.owl
	 $(ROBOT) convert --input $< --check false --output $@

subsets/%.owx: subsets/%.owl
	 $(ROBOT) convert --input $< --output $@
