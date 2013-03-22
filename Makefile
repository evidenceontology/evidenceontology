SRC = eco-edit.obo
TGT = eco.owl

release: $(TGT)

$(TGT): $(SRC)
	ontology-release-runner --reasoner elk $< --outdir .
