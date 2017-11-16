# Standard Make variables
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.DEFAULT_GOAL := all

# Project-specific variables
year = 2017
month = 10

tabula-download = "https://github.com/tabulapdf/tabula-java/releases/download/0.9.2/tabula-0.9.2-jar-with-dependencies.jar"
tabula = java -jar tabula-java/tabula-0.9.2-jar-with-dependencies.jar
pdf-pages = $$(pdfinfo "$$pdf" | grep Pages | perl -p -e 's/[^[0-9]*//')

FORMAT_PERCENTAGES = sed -e "s/+ //g" -e "s/- /-/g" -e "s/\%//g"
