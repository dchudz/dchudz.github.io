Here are blog posts in their source form, mostly markdown + code.

For Julia, I used [Judo](https://github.com/dcjones/Judo.jl) to compile the markdown + Julia. The bash script `judoblog` in this directory is a small helper.

For R, I'm using `knitr` to execute `Rmd` files. The R script `RmdToPost.R` in this directory is a smaller helper. The makefile says everything you need to know. (I wasn't using a makefile yet when I wrote the post with Julia.)

LaTeX is wrapped in a code (single or triple backticks) to protect it from markdown rendering. For code blocks with LaTeX the `has-jax` class is applied, and the css rule for rendering code is told not to apply to that class. This approach is based on http://cwoebker.com/posts/latex-math-magic, but the ideas outlined there didn't quite work for me.