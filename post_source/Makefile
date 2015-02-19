# Steps to include an iPython notebook as a blog post:
# 1) Create notebook
# 2) run: ipython nbconvert --to=html --template basic  --ExecutePreprocessor.enabled=True (notebook)
# - is there some way to avoid having line numbers appear in the python?
# 2) add the yaml 
# 3) replace "{{" with "{ {" due to some bug in jekyll (I updated jekyll, still a problem)
# 



INTERACTION_OR_NOT_DATE := 2015-02-02
INTERACTION_OR_NOT_NAME := interaction-or-not
INTERACTION_OR_NOT := ../_posts/$(INTERACTION_OR_NOT_DATE)-$(INTERACTION_OR_NOT_NAME).md

$(INTERACTION_OR_NOT): $(INTERACTION_OR_NOT_NAME).Rmd
	rm -f ../_posts/*-$(INTERACTION_OR_NOT_NAME).md
	Rscript RmdToPost.R $(INTERACTION_OR_NOT_NAME).Rmd $(INTERACTION_OR_NOT_DATE)

TREES_DIR = ../images/posts/interaction-or-not-trees/
$(TREES_DIR)/tree.png: interaction-or-not/tree.tex
	latex -output-format='pdf' -output-dir=../images/posts/interaction-or-not-trees/ $^
	convert -density 300 $(TREES_DIR)/tree.pdf -resize 50% $@

$(TREES_DIR)/two-trees.png: interaction-or-not/two-trees.tex
	latex -output-format='pdf' -output-dir=../images/posts/interaction-or-not-trees/ $^
	convert -density 300 $(TREES_DIR)/two-trees.pdf -resize 50% $@

$(TREES_DIR)/two-trees-wrong.png: interaction-or-not/two-trees-wrong.tex
	latex -output-format='pdf' -output-dir=../images/posts/interaction-or-not-trees/ $^
	convert -density 300 $(TREES_DIR)/two-trees-wrong.pdf -resize 50% $@


interaction-or-not: $(INTERACTION_OR_NOT) $(TREES_DIR)/tree.png $(TREES_DIR)/two-trees.png $(TREES_DIR)/two-trees-wrong.png

PRES_INTERACTION_OR_NOT_NO_BART := ../slides/pres-interaction-or-not-no-bart.html
$(PRES_INTERACTION_OR_NOT_NO_BART): presentations/interaction-or-not-no-bart.Rmd
	Rscript -e " \
	library(knitr); \
	knit('presentations/interaction-or-not-no-bart.Rmd', output='../slides/pres-interaction-or-not-no-bart.md'); \
	system(paste('pandoc -s -S -i -t slidy --mathjax', '../slides/pres-interaction-or-not-no-bart.md', '-o', '../slides/pres-interaction-or-not-no-bart.html'))"

PRES_INTERACTION_OR_NOT_WITH_BART := ../slides/pres-interaction-or-not-with-bart.html
$(PRES_INTERACTION_OR_NOT_WITH_BART): presentations/interaction-or-not-with-bart.Rmd
	Rscript -e " \
	library(knitr); \
	knit('presentations/interaction-or-not-with-bart.Rmd', output='../slides/pres-interaction-or-not-with-bart.md'); \
	system(paste('pandoc -s -S -i -t slidy --mathjax', '../slides/pres-interaction-or-not-with-bart.md', '-o', '../slides/pres-interaction-or-not-with-bart.html'))"


interaction-or-not-slides: $(PRES_INTERACTION_OR_NOT_NO_BART) $(PRES_INTERACTION_OR_NOT_WITH_BART)

