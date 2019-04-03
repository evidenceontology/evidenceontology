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

#update: build/robot.jar | modules imports
.PHONY: update
update: modules imports
all: report build mapping subsets
release: all

# test is used for Travis integration
test: report verify

# ----------------------------------------
# ROBOT
# ----------------------------------------

init: $(BUILD)
$(BUILD):
	mkdir -p $@

#.PHONY: build/robot.jar
#build/robot.jar: | init
	#curl -L -o $(BUILD)robot.jar\
	 #https://build.berkeleybop.org/job/robot/lastSuccessfulBuild/artifact/bin/robot.jar

ROBOT := java -jar build/robot.jar

# ----------------------------------------
# MODULES
# ----------------------------------------

TEMP = src/ontology/templates/
MOD = src/ontology/modules/

modules: $(MOD)obi_logic.owl

$(MOD)obi_logic.owl: $(TEMP)obi_logic.csv
	$(ROBOT) merge --input-iri http://purl.obolibrary.org/obo/obi.owl\
	 --input-iri http://purl.obolibrary.org/obo/go.owl\
	 template --template $<\
	 annotate --ontology-iri "$(OBO)$(ECO)/modules/obi_logic.owl" --output $@

# ----------------------------------------
# IMPORTS
# ----------------------------------------

IMP = src/ontology/imports/
IMPS = go obi

imports: $(IMPS)

$(IMPS): $(MOD)obi_logic.owl
	python $(IMP)get_terms.py $@ &&\
	 robot extract --input-iri "$(OBO)$@.owl"\
	 --method bot --term-file $(IMP)$@_terms.txt --term-file $(IMP)etc_terms.txt\
	 remove --select "complement" --select "annotation-properties" --trim true \
	 --term-file $(IMP)annotations.txt\
	 annotate --ontology-iri "$(OBO)eco/imports/$@_import.owl"\
	 --output $(IMP)$@_import.owl

# ----------------------------------------
# REPORT
# ----------------------------------------

# A report is written to build/reports/report.tsv

report: $(BUILD)report.tsv
.PHONY: $(BUILD)report.tsv
$(BUILD)report.tsv: $(EDIT) # init
	$(ROBOT) report --input $<\
	 --output $@ --format tsv

# verify is part of 'test' for Travis

V_QUERIES := $(wildcard $(SPARQL)verify-*.rq)
.PHONY: verify
verify: init
	$(ROBOT) verify --input $(EDIT)\
	 --queries $(V_QUERIES) --output-dir $(BUILD)

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
TS = $(shell date +'%m:%d:%Y %H:%M')
DATE = $(shell date +'%Y-%m-%d')

$(ECO).owl: $(EDIT)
	$(ROBOT) merge --input $< --collapse-import-closure true \
	 reason --reasoner elk --create-new-ontology false \
	 --annotate-inferred-axioms true --exclude-duplicate-axioms true \
	 annotate --version-iri "$(OBO)eco/releases/$(DATE)/eco.owl" \
	 --annotation oboInOwl:date "$(TS)" --output $@

$(ECO).obo: $(ECO).owl
	$(ROBOT) convert --input $< --format obo --check false\
	 --output $(basename $@)-temp.obo && \
	grep -v ^owl-axioms $(basename $@)-temp.obo > $@ && \
	rm $(basename $@)-temp.obo

$(BASE).owl: $(EDIT)
	$(ROBOT) remove --input $< --select imports \
	annotate --ontology-iri "$(OBO)eco/$@"\
	 --version-iri "$(OBO)eco/releases/$(DATE)/$@"\
	 --annotation oboInOwl:date "$(TS)" --output $@

$(BASIC).owl: $(EDIT)
	$(ROBOT) remove --input $< --select imports --trim true \
	reason --reasoner elk --annotate-inferred-axioms false reduce \
	remove --select "equivalents parents" --select "anonymous" \
	annotate --ontology-iri "$(OBO)eco/$@"\
	 --version-iri "$(OBO)eco/releases/$(DATE)/$@"\
	 --annotation oboInOwl:date "$(TS)" --output $@

$(BASIC).obo: $(BASIC).owl
	$(ROBOT) convert --input $< --format obo --check false\
	 --output $(basename $@)-temp.obo && \
	grep -v ^owl-axioms $(basename $@)-temp.obo > $@ && \
	rm $(basename $@)-temp.obo

# ----------------------------------------
# MAPPINGS
# ----------------------------------------

mapping: gaf-eco-mapping-derived.txt

# create derived GO mapping file
gaf-eco-mapping-derived.txt: $(ECO).owl
	$(ROBOT) query --input $(ECO).owl --format tsv\
	 --select $(SPARQL)make-derived-mapping.rq build/$@ \
	&& sed 's/\"//g' build/$@\
	 | sed 's/\^\^<http:\/\/www\.w3\.org\/2001\/XMLSchema#string>//g'\
	 | tail -n +2 > $@

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

$(SUBS): $(ECO).owl
	$(ROBOT) filter --input $< \
	 --select "oboInOwl:inSubset=<http://purl.obolibrary.org/obo/eco#$@> annotations" \
	 annotate --version-iri "http://purl.obolibrary.org/obo/eco/$(DATE)/subsets/$@.owl"\
	 --ontology-iri "http://purl.obolibrary.org/obo/eco/subsets/$@.owl"\
	 --output $(addprefix $(SUB), $(addsuffix .owl, $@))\
	 && $(ROBOT) convert --input $(addprefix $(SUB), $(addsuffix .owl, $@))\
	 --output $(addprefix $(SUB), $(addsuffix .obo, $@)) --check false\
	 && $(ROBOT) convert --input $(addprefix $(SUB), $(addsuffix .owl, $@))\
	 --output $(addprefix $(SUB), $(addsuffix .owx, $@))
