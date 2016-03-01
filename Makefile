SRC = eco-edit.obo
TGT = eco.owl

all: $(TGT)
release: all
test: all

$(TGT): $(SRC)
	ontology-release-runner --allow-overwrite --simple-filtered --simple --reasoner hermit --useIsInferred $< --outdir .

deploy: $(TGT)
#$(TGT): main/$(TGT)
#	cp -pr main/* .

eco-simple.obo: eco.owl
subsets/eco-basic.obo: eco-simple.obo
	grep -v ^disjoint $< | perl -npe 's@ontology: eco.*@ontology: eco/subsets/eco-basic.obo@' > $@

release-diffs:
	cd diffs && make
