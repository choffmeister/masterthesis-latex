all: pdf bib

pdf:
	pdflatex -file-line-error -interaction=nonstopmode -synctex=1 -etex src/main.tex

bib:
	bibtex8 main.aux
	bibtex8 main.gls.aux

clean:
	find . -name '*.log' -print0 | xargs -0 rm -f
	find . -name '*.aux' -print0 | xargs -0 rm -f
	find . -name '*.toc' -print0 | xargs -0 rm -f
	find . -name '*.out' -print0 | xargs -0 rm -f
	find . -name '*.bbl' -print0 | xargs -0 rm -f
	find . -name '*.blg' -print0 | xargs -0 rm -f
	find . -name '*~' -print0 | xargs -0 rm -f
	find . -name '*.synctex.gz' -print0 | xargs -0 rm -f
	find . -name '*.synctex.gz(busy)' -print0 | xargs -0 rm -f