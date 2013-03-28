SRC = eco-edit.obo
TGT = eco.owl

release: main/$(TGT)
main/$(TGT): $(SRC)
	ontology-release-runner --allow-overwrite --reasoner elk $< --outdir main

deploy: $(TGT)
$(TGT): main/$(TGT)
	cp -pr main/* .
