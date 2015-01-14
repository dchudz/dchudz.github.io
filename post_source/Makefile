
INTERACTION_OR_NOT_DATE := 2015-01-14
INTERACTION_OR_NOT_NAME := interaction-or-not
INTERACTION_OR_NOT := ../_posts/$(INTERACTION_OR_NOT_DATE)-$(INTERACTION_OR_NOT_NAME).md
interaction-or-not: $(INTERACTION_OR_NOT)
$(INTERACTION_OR_NOT): $(INTERACTION_OR_NOT_NAME).Rmd
	rm -f ../_posts/*-$(INTERACTION_OR_NOT_NAME).md
	Rscript RmdToPost.R $(INTERACTION_OR_NOT_NAME).Rmd $(INTERACTION_OR_NOT_DATE)


# bart-posts: bart-machine-1

# BART_MACHINE_1_DATE := 2014-07-06
# BART_MACHINE_1_NAME := bart-machine-simple-examples-discrete
# BART_MACHINE_1 := ../_posts/$(BART_MACHINE_1_DATE)-$(BART_MACHINE_1_NAME).md
# bart-machine-1: $(BART_MACHINE_1)
# $(BART_MACHINE_1): $(BART_MACHINE_1_NAME).Rmd
# 	rm -f ../_posts/*-$(BART_MACHINE_1_NAME).md
# 	Rscript RmdToPost.R $(BART_MACHINE_1_NAME).Rmd $(BART_MACHINE_1_DATE)



# BART_MACHINE_2_DATE = 2014-07-10
# BART_MACHINE_2_NAME = bart-machine-simple-examples-continuous
# ../_posts/$(BART_MACHINE_1_DATE)-$(BART_MACHINE_2_NAME).md: $(BART_MACHINE_1_NAME).Rmd
# 	rm ../_posts/*-$(BART_MACHINE_1_NAME).md
# 	Rscript RmdToPost.R $(BART_MACHINE_1_NAME).Rmd $(BART_MACHINE_1_DATE)
