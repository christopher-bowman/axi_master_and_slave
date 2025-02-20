
#
# Copyright (C) 2025 Christopher R. Bowman.  All rights reserved
# contact: <my initials>@ChrisBowman.com
#
# This make file builds the project documentation
#

.SUFFIXES: .tex .dvi .pdf .lot .toc .ps

all: doc

help:
	@echo "targets:"
	@echo "========"
	@echo "doc               build the project specification pdf"
	@echo "view              run evince on the specification pdf"
	@echo "specification.ps  bulid a postscript version of the specification"

doc: specification.pdf

%.toc: %.tex
	latex $<

%.lot: %.tex
	latex $<

#%.dvi: %.lot %.toc %.tex
#	@echo "built .lot and .toc"
#	latex $<

.tex.dvi: # override the built in
	latex $<
	latex $<

.dvi.pdf:
	dvipdf $<

.dvi.ps:
	dvips $<

view: doc
	evince specification.pdf

clean: 
	rm -rf specification.dvi specification.toc specification.lot specification.log specification.aux specification.pdf specification.ps specification.out

.PHONY: doc
