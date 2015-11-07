../resume.pdf: resume.tex resume.cls
	latex -halt-on-error -output-format='pdf' resume.tex
	mv resume.pdf $@ 
	open ../resume.pdf