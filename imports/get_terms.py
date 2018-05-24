import re
import sys

eco_path = "modules/obi_logic.owl"
ns = sys.argv[1]
term_file_path = "imports/" + ns + "_terms.txt"

regex = re.compile(ns + "_[0-9]{7}")

def file_to_str(filename):
	with open(filename) as f:
		return f.read().lower()

def get_obi_terms(s):
	return (term for term in re.findall(regex, s))

if __name__ == '__main__':
    curies = []
    for term in get_obi_terms(file_to_str(eco_path)):
        curie = term.replace("_", ":").upper()
        curies.append(curie)
    term_file = open(term_file_path, "w")
    term_file.write("\n".join(curies))
    term_file.close()
