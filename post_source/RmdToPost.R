rmdFile <- commandArgs(trailingOnly = TRUE)[1]
date <- commandArgs(trailingOnly = TRUE)[2]

rmdFile <- "bart-machine-simple-examples-discrete.Rmd"
date <- "2014-07-06"

baseName <- tools::file_path_sans_ext(rmdFile)
cat(sprintf("Turning %s into a post dated %s\n", rmdFile, date))

library(knitr)



opts_knit$set(base.dir = "..")
opts_chunk$set(fig.path=sprintf("images/posts/%s/", baseName))
knit2html(rmdFile, output=sprintf('../_posts/%s-%s.WRONGPATHS.md', date, baseName))



system(sprintf("sed 's/images\\/posts/\\/images\\/posts/g' ../_posts/%s-%s.WRONGPATHS.md > ../_posts/%s-%s.md",
       date, baseName, date, baseName))



file.remove(sprintf('../_posts/%s-%s.WRONGPATHS.md', date, baseName))
file.remove(sprintf('../_posts/%s-%s.WRONGPATHS.html', date, baseName))
