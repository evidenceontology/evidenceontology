## Syncing with repo

Always do this before commencing editing:

```
cd evidenceontology
git pull
```

## Editing

Open `eco-edit.obo` in OBO-Edit, make changes as necessary.
Save your work, then commit

Committing:

(you should still be in the evidenceontology folder)

```
git commit -m "my fabulous edits" eco-edit.obo
git push origin master
```

(see TIPS below)

## Post-editing steps

* Check Jenkins

http://build.berkeleybop.org/job/build-eco/

## TIPS

You can automatically close a tracker item from a commit like this:

```
git commit -m "Added inferred-by-blog-article, Fixes #20" eco-edit.obo
```

(substitute "20" with your issue number here)

## MAKING RELEASES

The -edit file is generally not visible to the public (of course they
can find it in github if they try). The editors are free to make
changes they are not yet comfortable releasing.

When ready for release, the process is as follows:

First check the file is valid - see the Jenkins job below. Additional
spot checks would not do any harm.

Type:

    make release

(you will need owltools and/or robot)

This generates derived files such as eco.owl and eco.obo. The
versionIRI will be added.

Commit and push these files.

IMMEDIATELY AFTERWARDS (do *not* make further modifications) go here:

 * https://github.com/obophenotype/eco/releases
 * https://github.com/obophenotype/eco/releases/new

The value of the "Tag version" field MUST be

    vYYYY-MM-DD

The initial lowercase "v" is REQUIRED. The YYYY-MM-DD *must* match
what is in the versionIRI of the derived eco.owl (data-version in
eco.obo).

Release title should be YYYY-MM-DD, optionally followed by a title (e.g. "january release")

Then click "publish release"

NO MORE THAN ONE RELEASE PER DAY.

In addition, this will be picked up by the central obolibrary job
within 24hrs, which will produce two files:

 1. http://purl.obolibrary.org/obo/eco.obo
 2. http://purl.obolibrary.org/obo/eco.owl

This is used by obolibrary users and OWL people

For questions on this contact Chris Mungall or email obo-admin AT obofoundry.org



