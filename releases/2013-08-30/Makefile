SRC = eco-edit.obo
TGT = eco.owl

all: main/$(TGT)
release: all release-diffs

main/$(TGT): $(SRC)
	ontology-release-runner --allow-overwrite --reasoner elk $< --outdir .

deploy: $(TGT)
$(TGT): main/$(TGT)
	cp -pr main/* .

release-diffs:
	cd diffs && make
