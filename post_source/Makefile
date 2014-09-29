all: bart-posts

BART_MACHINE_1_DATE = 2014-07-06
BART_MACHINE_1_NAME = bart-machine-simple-examples-discrete
../_posts/$(BART_MACHINE_1_DATE)-$(BART_MACHINE_1_NAME).md: $(BART_MACHINE_1_NAME).Rmd
	rm ../_posts/*-$(BART_MACHINE_1_NAME).md
	Rscript RmdToPost.R $(BART_MACHINE_1_NAME).Rmd $(BART_MACHINE_1_DATE)



BART_MACHINE_2_DATE = 2014-07-10
BART_MACHINE_2_NAME = bart-machine-simple-examples-continuous
../_posts/$(BART_MACHINE_1_DATE)-$(BART_MACHINE_2_NAME).md: $(BART_MACHINE_1_NAME).Rmd
	rm ../_posts/*-$(BART_MACHINE_1_NAME).md
	Rscript RmdToPost.R $(BART_MACHINE_1_NAME).Rmd $(BART_MACHINE_1_DATE)


bart-posts: ../_posts/$(BART_MACHINE_1_DATE)-$(BART_MACHINE_1_NAME).md ../_posts/$(BART_MACHINE_2_DATE)-$(BART_MACHINE_2_NAME).md
