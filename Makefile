SRC = eco-edit.obo
TGT = eco.owl

release: $(TGT)

$(TGT): $(SRC)
	ontology-release-runner --allow-overwrite --reasoner elk $< --outdir main
