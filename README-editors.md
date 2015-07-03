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


