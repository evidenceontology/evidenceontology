
Fetching the latest version:

Always do this before commencing editing:

---
cd evidenceontology
svn update
---

Editing:

Open eco-edit.obo in OBO-Edit, make changes as necessary.
Save your work, the commit

Committing:

(you should still be in the evidenceontology folder)

---
svn commit -m "my fabulous edits" eco-edit.obo
---

(see TIPS below)

Post-editing steps:

* Check Jenkins

http://build.berkeleybop.org/job/build-eco/

TIPS:

You can automatically close a tracker item from a commit like this:

---
svn commit -m 'Fixes issue 20' eco-edit.obo
---

(substitute "20" with your issue number here)


