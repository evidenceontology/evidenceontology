import re
import sys

eco_path = sys.argv[1]
ns = sys.argv[2]
output = sys.argv[3]
regex = re.compile(ns + "_[0-9]{7}")


def file_to_str(filename):
	with open(filename) as f:
		return f.read().lower()


def get_obi_terms(s):
	return (term for term in re.findall(regex, s))


if __name__ == '__main__':
    curies = set()
    print(eco_path)
    for term in get_obi_terms(file_to_str(eco_path)):
        curie = term.replace("_", ":").upper()
        curies.add(curie)
    curies = sorted(curies)
    term_file = open(output, "w")
    term_file.write("\n".join(curies))
    term_file.close()
