SRC = eco-edit.owl
TGT = eco.owl
DRV = gaf-eco-mapping-derived.txt

all: $(TGT)
release: all
test: all

$(TGT): $(SRC)
	ontology-release-runner --allow-overwrite --simple-filtered --simple --reasoner hermit --useIsInferred $< --outdir .
	stardog-admin db create -n eco2 -o icv.reasoning.enabled=true -- $(TGT)
	stardog query -f TSV eco2 patterns/query.rq | sed 's/\"//g' | tail -n +2 > $(DRV)
	stardog-admin db drop eco2

deploy: $(TGT)
#$(TGT): main/$(TGT)
#	cp -pr main/* .

eco-simple.obo: eco.owl
subsets/eco-basic.obo: eco-simple.obo
	grep -v ^disjoint $< | perl -npe 's@ontology: eco.*@ontology: eco/subsets/eco-basic.obo@' > $@

release-diffs:
	cd diffs && make
	
