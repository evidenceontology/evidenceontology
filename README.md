**ABOUT ECO**

**[Please cite the most recent ECO paper](https://academic.oup.com/database/article/doi/10.1093/database/bau075/2634798/Standardized-description-of-scientific-evidence)** (see references below).

The **[Evidence & Conclusion Ontology (ECO)](http://www.evidenceontology.org/)** describes types of scientific evidence within the biological research domain that arise from laboratory experiments, computational methods, literature curation, or other means. Researchers use evidence to support conclusions that arise out of scientific research. Documenting evidence during scientific research is essential, because evidence gives us a sense of _why_ we believe what we _think_ we know. Conclusions are asserted as statements about things that are believed to be true, for example that a protein has a particular function (i.e. a protein functional annotation) or that a disease is associated with a particular gene variant (i.e. a phenotype-gene association). A systematic and structured (i.e. ontological) classification of evidence allows us to store, retreive, share, and compare data associated with that evidence using computers, which are essential to navigating the ever-growing (in size and complexity) corpus of scientific information.

ECO is an ontology comprising two root (upper-level) classes, 'evidence' and 'assertion method', where **'evidence'** is defined as "a type of information that is used to support an assertion" and **'assertion method'** is defined as "a means by which a statement is made about an entity." Together 'evidence' and 'assertion method' can be combined to describe both the _supporting evidence_ for an assertion (such as a gene product annotation) and _the agent who made the assertion_, i.e. a human being or a computer. However, ECO can not be used to make an assertion itself; for that, one would use some other means, such as another ontology, controlled vocabulary, or <nowiki>[less desirably]</nowiki> a free text description.

ECO was originally created around the year 2000 to support [Gene Ontology (GO)](http://geneontology.org/) gene product annotations. GO continues to use ECO, now in the [AmiGO2](http://amigo2.geneontology.org/amigo) browser, [Noctua](http://noctua.berkeleybop.org/) web-based tool, and other applications. Today, **[many projectss use ECO](http://www.evidenceontology.org/about_us/#usergroups)** to document evidence information in scientific research, including protein & gene resources, model organism databases, software applications, phenotype projects, and more. ECO collaborates with the [Ontology for Biomedical Investigations](http://obi-ontology.org) Consortium in order to achieve [harmonious interactions](https://f1000research.com/posters/6-395). ECO is committed to the principles established by the [Open Biological and Biomedical Ontologies Foundry](http://obofoundry.org/) (OBO Foundry).

***

**DEVELOPMENT INFORMATION**

If you want to **help grow ECO for your own project** please contact us via the **GitHub Issue tracker**. If you are new to ECO, please take a look at our **Rules for New Term Requests** on the **[ECO website](http://www.evidenceontology.org/userguide/#newtermrules)** or the **[ECO GitHub wiki](https://github.com/evidenceontology/evidenceontology/wiki/New-term-request-how-to)**... and thanks! 

*****When you contribute your knowledge to ECO, everyone benefits.*****

For **advice on requesting new terms**, please see the **[ECO GitHub wiki](https://github.com/evidenceontology/evidenceontology/wiki/New-term-request-how-to)**.

For **information about editing & releases**, please see the **[GitHub editors README file](https://github.com/evidenceontology/evidenceontology/blob/master/src/ontology/README-editors.md)**.

For **further information** including history, detailed discussion of evidence, and a complete bibliography, please visit the **[Evidence & Conclusion Ontology website](http://www.evidenceontology.org/)**.

***

**PLEASE CITE ECO & follow us on Twitter**

Follow us on **[Twitter](https://twitter.com/ecoontology)**.

_ECO is free for all to use without restriction - see **CC0** information below. But we certainly appreciate attribution. If you use ECO in your work, please consider citing ECO._

**Cite** this paper:

[Chibucos MC, Mungall CJ, Balakrishnan R, Christie KR, Huntley RP, White O, Blake JA, Lewis SE, and Giglio M. (2014) **Standardized description of scientific evidence using the Evidence Ontology (ECO)**. _Database_. Vol. **2014**: article ID bau066. PMID:25052702.](http://database.oxfordjournals.org/content/2014/bau075.long)

**Other publications _about_ ECO**:

[Tauber R & Chibucos MC. (2017) **Logical axiomatization of the Evidence & Conclusion Ontology (ECO) by integrating external ontology classes**, in Proc. of the 8th International Conference on Biomedical Ontology (ICBO 2017), September 13-15, 2017, Newcastle-upon-Tyne, United Kingdom. Edited by: Matthew Horridge, Phillip Lord, Jennifer D. Warrender.](http://ceur-ws.org/Vol-2137/paper_25.pdf)

[Chibucos MC, Hu JC, Siegele DA, Giglio M. (2016) **The Evidence and Conclusion Ontology (ECO): Supporting GO Annotations**. In Christophe Dessimoz & Nives Škunca (eds.), The Gene Ontology Handbook, Methods in Molecular Biology, vol. 1446, pp. 245-259. New York City: Humana Press (Springer). ISBN:978-1-4939-3743-1.](https://link.springer.com/protocol/10.1007%2F978-1-4939-3743-1_18)

[Chibucos MC, Nadendla S, Munro JB, Mitraka E, Olley D, Vasilevsky NA, Brush MH, Giglio M. (2016) **Supporting database annotations and beyond with the Evidence & Conclusion Ontology (ECO)**, in Proc. of the Joint International Conference on Biological Ontology and BioCreative, August 1-4, 2016, Corvalis, OR, USA. Edited by: Pankaj Jaiswal, Robert Hoehndorf, Cecilia Arighi, Austin Meier.](http://ceur-ws.org/Vol-1747/IP30_ICBO2016.pdf)

***

**LICENSING**

ECO is released into the public domain under **CC0 1.0 Universal (CC0 1.0)**. Anyone is free to copy, modify, or distribute the work, even for commercial purposes, without asking permission. Please see the **[Public Domain Dedication](https://creativecommons.org/publicdomain/zero/1.0/)** for an easy-to-read description of CC0 1.0 or the **[full legal code](https://creativecommons.org/publicdomain/zero/1.0/legalcode)** for more detailed information. To get a sense of _why_ **ECO is CC0** as opposed to licensed under **CC-BY**, please read this **[thoughtful discussion](https://github.com/OBOFoundry/OBOFoundry.github.io/issues/285)** on the OBO Foundry GitHub site.

***

**FUNDING ACKNOWLEDGEMENT**

This material (the ontology & related resources) is based upon work supported by the **National Science Foundation Division of Biological Infrastructure** under **[Award Number 1458400](http://www.nsf.gov/awardsearch/showAward?AWD_ID=1458400)** to Dr. Marcus Chibucos, the original Principal Investigator, and to Dr. Michelle Giglio, the current Principal Investigator.

Prior development was supported in part by **National Institutes of Health/National Institute of General Medical Sciences** under **[Grant Number 2R01GM089636](https://projectreporter.nih.gov/project_info_description.cfm?aid=8579651&icde=0)** and by **[Dr. Owen White](http://www.medschool.umaryland.edu/profiles/White-Owen/)**.
