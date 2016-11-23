
# Getting Started
-------
### Download Protégé
Latest verison is 5.1.0. [Download here](http://protege.stanford.edu/products.php#desktop-protege) and follow the documentation on their wiki.

### Clone the ECO repository
```
git clone https://github.com/evidenceontology/evidenceontology.git
```

### Sync with the repo
Always do this before commencing editing:

```
cd evidenceontology
git pull
```

# Editing
-------
### Minor Edits
Open `eco-edit.owl` in Protégé, make changes as necessary. Save your work, then commit.

### Run the Reasoner
Before saving any changes, it is a good idea to run the reasoner. The ELK reasoner should be selected in Protégé (ELK 0.4.3 for Protege-OWL 5). Start the reasoner, and ignore the alerts that state reasoning may be incomplete and that axiom is ignored. For more information on ELK, [visit the wiki](http://protegewiki.stanford.edu/wiki/ELK).

### Commit

From your local evidenceontology directory:
```
git commit -m "my fabulous edits" eco-edit.obo
git push origin master
```

You can automatically close a tracker item from a commit like this:
```
git commit -m "Added inferred-by-blog-article, Fixes #20" eco-edit.obo
```
(substitute "20" with your issue number here)

### Major Edits
For addition or update of multiple terms at once, we recommend the use of [ROBOT](https://github.com/ontodev/robot). Visit their GitHub (linked) for installation instructions.

ROBOT includes a template tool to build OWL files from a CSV spreadsheet. The easiest way to edit these spreadsheets is in Excel, then save as CSV. Start off with our [ECO ROBOT Template](https://github.com/evidenceontology/evidenceontology/blob/master/editors/eco-robot-template.csv) and add your desired terms. The first row contains headers, which ROBOT ignores. The second row contains the template string for the OWL conversion. These two rows should not be changed. Our template includes the following:

| Header        | Template String          | Description  |
| ------------- |--------------------------| -----|
| ID | ID | Unique ID for term (ECO:xxxxxxx).|
| OBO ID | A oboInOwl:id | Annotation property to display ID, should be the same as ID. |
| Label | A rdfs:label | Textual label for term ('...evidence'). |
| Definition | A obo:IAO_0000115 | Aristotelian definition ('A type of [parent evidence]...'). |
| Namespace | A oboInOwl:hasOBONamespace | Should always be 'eco'.
| CreatedBy | A oboInOwl:created_by | Reference to the creator of term (i.e. jdoe). |
| Date | A oboInOwl:creation_date | Formated date (i.e. 2016-12-29T16:01:01Z). |
| ParentIRI | CI | ID of parent class (ECO:xxxxxxx). |
| Synonym | A oboInOwl:hasExactSynonym | Exact synonym. For related, broad, or narrow synonyms use the respective annotation properties. |
| Comment | A rdfs:comment | Clarification of definition or for use case. |

This is not an exhaustive list of the annotation properties used in ECO, but it is what is recommended for a new term. Synonym and Comment are not necessary, but may add clarity. Any cell that is left blank will not be tranlsated into OWL.

Once you are done adding terms to the spreadsheet, save it as CSV and run the following command:
```
robot template --template [PATH_TO_CSV] 
    --prefix "eco: http://purl.obolibrary.org/obo/eco#" \
    --ontology-iri "http://purl.obolibrary.org/obo/eco.owl" \
    --output [NAME_OF_OUTPUT.OWL]
```
Replace `[PATH_TO_CSV]` with the path to your file (i.e. `~/Documents/template.csv`) and `[NAME_OF_OUTPUT.OWL]` with a temporary name such as `new-terms.owl`. This command will generate a new OWL file consisting of your terms. Placeholders with the parent IDs will be created for super classes. 

Check your new OWL file to make sure everything looks good, then merge it into `eco-edit.owl` (this should be done from the evidenceontology subdirectory):
```
robot merge --input [PATH_TO_PREVIOUS_OUTPUT.OWL] 
    --input eco-edit.owl \
    --output [NAME_OF_OUTPUT.OWL]
```
Replace `[PATH_TO_PREVIOUS_OUTPUT.OWL]` with the path to the output from the template step (i.e. `~/Documents/new-terms.owl`). The output (`[NAME_OF_OUTPUT.OWL]`) will be a complete file which you can replace the original `eco-edit.owl` with (make sure to give it the same name!).

It is also possible to template and merge at the same time, though it may make proof-reading more difficult.
```
robot template --template [PATH_TO_CSV] 
    --merge-before --input eco-edit.owl \
    --prefix "eco: http://purl.obolibrary.org/obo/eco#" \
    --ontology-iri "http://purl.obolibrary.org/obo/eco.owl" \
    --output [NAME_OF_OUTPUT.OWL]
```

**Please note:**
ROBOT generates OWL files in RDF/XML syntax. `eco-edit.owl` is saved in OWL Functional Syntax. *Make sure* to open your final file (after merging) in Protege, SAVE AS and select 'OWL Function Syntax'. Simply replace your generated file with this new save to keep the format consistent.

### Post-editing steps

* Check Jenkins

http://build.berkeleybop.org/job/build-eco/


# Make Release
-----

The eco-edit file is generally not visible to the public (of course, they can find it in github if they try). The editors are free to make changes they are not yet comfortable releasing. Releases are typically done the first Friday of the month, unless there is an urgent need for an earlier release. Regardless, only **one** release should be done per day.

In order to do a release, [OWLTools](https://github.com/owlcollab/owltools) is required (OORT is used). Visit their GitHub (linked) for download and setup instructions. You will need to add OWLTools-Oort to your PATH (Environment Variables in Windows, `.bash_profile` for Mac and Linux).

When ready for release, first enter:

    make release

This generates derived files such as eco.owl and eco.obo. The versionIRI will be added. Immediately commit and push these files.

IMMEDIATELY AFTERWARDS (do *not* make further modifications) go here:

 * https://github.com/obophenotype/eco/releases
 * https://github.com/obophenotype/eco/releases/new

The value of the "Tag version" field MUST be

    vYYYY-MM-DD

The initial lowercase "v" is *REQUIRED*. The YYYY-MM-DD *MUST* match what is in the versionIRI of the derived eco.owl (data-version in eco.obo).

Release title should be YYYY-MM-DD, optionally followed by a title (e.g. "january release"). This is not as important as the "Tag version"

**Check that you have the tag version correct, then click "publish release".**

An example:

 * http://purl.obolibrary.org/obo/eco/releases/2015-07-03/eco.owl

This redirects to the version of eco from this github release:

 * https://github.com/evidenceontology/evidenceontology/releases/tag/v2015-07-03


For questions on this contact Chris Mungall or email obo-admin@obofoundry.org
