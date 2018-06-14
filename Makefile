# config
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:

# path vars
ECO = eco
EDIT = eco-edit.owl
OBO = http://purl.obolibrary.org/obo/

update: | modules imports
all: | modules imports report build mapping subsets
release: all

# ----------------------------------------
# ROBOT
# ----------------------------------------

ROBOT := java -jar build/robot.jar

# ----------------------------------------
# MODULES
# ----------------------------------------

TEMP = templates/
MOD = modules/

.PHONY: modules
modules: $(MOD)obi_logic.owl

.PHONY: $(MOD)obi_logic.owl
$(MOD)obi_logic.owl:
	robot merge --input-iri http://purl.obolibrary.org/obo/obi.owl\
	 --input-iri http://purl.obolibrary.org/obo/go.owl\
	 template --template $(TEMP)obi_logic.csv\
	 annotate --ontology-iri "$(OBO)$(ECO)/$@" --output $@

# ----------------------------------------
# IMPORTS
# ----------------------------------------

IMP = imports/
IMPS = go obi

.PHONY: imports
imports: $(IMPS)

$(IMPS):
	python $(IMP)get_terms.py $@ &&\
	 robot extract --input-iri "$(OBO)$@.owl"\
	 --method bot --term-file $(IMP)$@_terms.txt --term-file $(IMP)etc_terms.txt\
	 remove --select "complement annotation-properties"\
	 --entities $(IMP)annotations.txt\
	 annotate --ontology-iri "$(OBO)eco/imports/$@_import.owl"\
	 --output $(IMP)$@_import.owl

# ----------------------------------------
# REPORT
# ----------------------------------------

REP = build/reports/

report: $(REP)report.tsv

$(REP)report.tsv: $(EDIT)
	$(ROBOT) report --input $< --fail-on none\
	 --output $@ --format tsv

# ----------------------------------------
# MAIN
# ----------------------------------------

build: $(ECO).owl $(ECO).obo

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
	$(ROBOT) convert --input $< --format obo --check false --output $@


# ----------------------------------------
# MAPPINGS
# ----------------------------------------

mapping: gaf-eco-mapping-derived.txt

# create derived GO mapping file
gaf-eco-mapping-derived.txt: $(TGT)
	$(ROBOT) query --input $(TGT) --format tsv --select build/derived.sparql build/$@ \
	&& sed 's/\"//g' build/$@\
	 | sed 's/\^\^<http:\/\/www\.w3\.org\/2001\/XMLSchema#string>//g'\
	 | tail -n +2 > $@

# ----------------------------------------
# SUBSETS
# ----------------------------------------

SUB = subsets/
SUBS = go_groupings \
valid_with_biological_process \
valid_with_cellular_component \
valid_with_chemical_entity \
valid_with_gene \
valid_with_molecular_function \
valid_with_protein \
valid_with_protein_complex

.PHONY: subsets
subsets: $(SUBS)

$(SUBS): eco.owl
	$(ROBOT) filter --input $< \
	 --select "oboInOwl:inSubset=<http://purl.obolibrary.org/obo/eco#$@> annotations"\
	 annotate --version-iri "http://purl.obolibrary.org/obo/eco/$(DATE)/subsets/$@.owl"\
	 --ontology-iri "http://purl.obolibrary.org/obo/eco/subsets/$@.owl"\
	 --output $(addprefix $(SUB), $(addsuffix .owl, $@))\
	 && $(ROBOT) convert --input $(addprefix $(SUB), $(addsuffix .owl, $@))\
	 --output $(addprefix $(SUB), $(addsuffix .obo, $@)) --check false\
	 && $(ROBOT) convert --input $(addprefix $(SUB), $(addsuffix .owl, $@))\
	 --output $(addprefix $(SUB), $(addsuffix .owx, $@))
