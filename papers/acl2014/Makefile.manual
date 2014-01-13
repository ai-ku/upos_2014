TEX=abstract.tex introduction.tex representation.tex algorithm.tex experiments.tex token.tex features.tex paradigma.tex multi.tex discussion.tex related.tex contribution.tex appendix.tex 
FIG=scode-ex.png clustering_graph_mono.png baseline_graph_mono.png hinton.png plot-s-cl.pdf plot-d-cl.pdf plot-z-cl.pdf paradigmatic.png ksmooth.pdf

posind_cl.pdf: posind_cl.tex posind_cl.bbl ${TEX}
	pdflatex $<

posind_cl.bbl: posind2012.bib posind_cl.tex ${TEX}
	bibtex posind_cl

ksmooth.out: ksmooth.r summarize.0.gz
	./$<

ksmooth.pdf: ksmooth.gp ksmooth.out
	./$<

