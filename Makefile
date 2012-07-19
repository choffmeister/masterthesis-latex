all:
	pdflatex -file-line-error -interaction=nonstopmode -etex src/main.tex
	bibtex8 main.aux

clean:
	find . -name '*.log' -print0 | xargs -0 rm -f
	find . -name '*.aux' -print0 | xargs -0 rm -f
	find . -name '*.toc' -print0 | xargs -0 rm -f
	find . -name '*.out' -print0 | xargs -0 rm -f
	find . -name '*.bbl' -print0 | xargs -0 rm -f
	find . -name '*.blg' -print0 | xargs -0 rm -f
	find . -name '*~' -print0 | xargs -0 rm -f