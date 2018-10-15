# Makefile für die Anfibriefe
# Fix fuer Ubuntu-User, bei denen anstatt bash dash verwendet wird
SHELL := /usr/bin/env bash
# Diese Variablen sollten für die aktuelle Version stimmen, müssen aber ggf.
# angepasst werden (am besten über Shell-Variablen, z. B. "export YEAR=2017"
# und "unset YEAR" zum Zurücksetzen):
YEAR ?= $(shell date '+%Y')
# Das Semester ist um 2 Monate nach vorne verschoben, da wir die Briefe ja vor
# dem entsprechenden Semester aktualisieren wollen.
SEMESTER ?= $(shell if [[ $$(date +%m) > 02 && $$(date +%m) < 07 ]]; then echo SS; else echo WS; fi)

# Variablen für die Build-Ordner
LETTERDIR = briefe
MISCDIR = misc
TIMETABLEDIR = stundenplaene
OUTDIR = out
PDFDIR ?= pdf
RELEASEDIR = final

# Test ob Inkscape installiert ist
INKSCAPE := $(shell inkscape --version 2> /dev/null)

# Liste was wo erstellt werden soll:
PLAENE = stpl_uebersicht stadtplan

# Zum SS koennen Info, Bioinfo sowie alle Master begonnen werden
SOMMERSEMESTER = $(PLAENE) brief_informatik-bsc brief_bioinfo-bsc brief_informatik-msc brief_bioinfo-msc brief_medieninfo-msc brief_medizininfo-msc brief_kogwiss-msc
# Zum WS kann man das aus dem SS beginnen plus zulassungsbeschraenkte Studiengaenge
WINTERSEMESTER = $(SOMMERSEMESTER) brief_medieninfo-bsc brief_medizininfo-bsc brief_kogwiss-bsc brief_informatik-lehramt

# Nur im Wintersemester müssen alle Briefe erstellt werden
ifeq ($(SEMESTER),WS)
  default: wintersemester
else
  default: sommersemester
endif

all: wintersemester

# A variable that later acts as a user-defined function
# "(call variable,parameter)"
env-replace = grep --extended-regexp --quiet '^\\newcommand\{\\$(1)\}\{$($(1))\}$$' env.tex ||\
	sed --regexp-extended --in-place 's/^\\newcommand\{\\$(1)\}\{.*\}$$/\\newcommand\{\\$(1)\}\{$($(1))\}/' env.tex
# A little (possibly dirty) hack to execute the env-update target every time at
# the beginning. This target updates the LaTeX variables in env.tex but only
# modifies the file if they actually differ (modifying the file causes the
# targets to rebuild which is intended).
-include env-update
.PHONY: env-update
env-update:
	@$(call env-replace,YEAR)
	@$(call env-replace,SEMESTER)
	@$(call env-replace,LETTERDIR)
	@$(call env-replace,MISCDIR)
	@$(call env-replace,TIMETABLEDIR)

# Mit diesem Target lassen sich die Stundenpläne und der Stadtplan erstellen
plaene: $(addprefix $(PDFDIR)/,$(addsuffix .pdf,$(PLAENE)))

# Mit diesem Target lassen sich die Briefe für das Sommersemester erstellen
sommersemester: $(addprefix $(PDFDIR)/,$(addsuffix .pdf,$(SOMMERSEMESTER)))

# Mit diesem Target lassen sich die Briefe für das Wintersemester erstellen
wintersemester: $(addprefix $(PDFDIR)/,$(addsuffix .pdf,$(WINTERSEMESTER)))

# Mit diesem Target lässt sich eine Übersicht über die Stundenpläne erstellen
#stundenplan: $(PDFDIR)/stpl_uebersicht.pdf # Alias
$(PDFDIR)/stpl_uebersicht.pdf: stpl_uebersicht.tex stpl_*.tex
	if [ ! -d $(OUTDIR) ]; then mkdir $(OUTDIR); fi
	latexmk -output-directory=$(OUTDIR) -pdf -pdflatex="pdflatex" $<
	if [ ! -d $(PDFDIR) ]; then mkdir $(PDFDIR); fi
	mv $(OUTDIR)/$(<:.tex=.pdf) $(PDFDIR)/$(<:.tex=.pdf)

# Mit diesem Target lässt sich der Stadtplan erstellen
#stadtplan: $(PDFDIR)/stadtplan.pdf # Alias
$(PDFDIR)/stadtplan.pdf: stadtplan.svg stadtplan.info
ifndef INKSCAPE
	$(warning Inkscape is missing! Skipping $@)
else
	if [ ! -d $(OUTDIR) ]; then mkdir $(OUTDIR); fi
	inkscape -C -T stadtplan.svg -A $(OUTDIR)/stadtplan.tmp
	if [ ! -d $(PDFDIR) ]; then mkdir $(PDFDIR); fi
	pdftk $(OUTDIR)/stadtplan.tmp update_info stadtplan.info output $(PDFDIR)/stadtplan.pdf
endif

# Mit diesem Target lässt sich ein bestimmter Brief erstellen
# TODO: Dropped "stpl_%_$(SEMESTER).tex" from the prerequisites since some
# timetables are missing. stundenplaene/stpl_%_$(YEAR)-$(SEMESTER).tex
$(PDFDIR)/brief_%.pdf: $(LETTERDIR)/brief_%.tex termine.tex misc.tex einleitung.tex logos/fsilogo.pdf config.tex mailinglisten.tex tuebingen.tex ps_zulassung.tex env.tex
	if [ ! -d $(OUTDIR) ]; then mkdir $(OUTDIR); fi
	latexmk -output-directory=$(OUTDIR) -pdf -pdflatex="pdflatex" $<
	if [ ! -d $(PDFDIR) ]; then mkdir $(PDFDIR); fi
	mv $(OUTDIR)/$(notdir $(<:.tex=.pdf)) $(PDFDIR)/$(notdir $(<:.tex=.pdf))

# Mit diesem Target können alle erzeugten Hilfsdateien (auxiliary files, e.g.
# .aux, .log) wieder entfernt werden
.PHONY: clean
clean:
	if [ -d $(OUTDIR) ]; then rm --recursive ./$(OUTDIR); fi

# Mit diesem Target können alle erzeugten Dateien wieder entfernt werden
.PHONY: mrproper
mrproper: clean
	if [ -d $(PDFDIR) ]; then rm --recursive ./$(PDFDIR); fi

# Mit diesem Target können restlos alle erzeugten Dateien wieder entfernt
# werden, d. h. auch die finalen Releases
.PHONY: distclean
distclean: mrproper
	if [ -d $(RELEASEDIR) ]; then rm --recursive ./$(RELEASEDIR); fi


# Mit diesem Target soll es *bald* (:P) einfach sein, die Hefte zu releasen
.PHONY: release
release: default rename
	mkdir -p $(RELEASEDIR)/$(YEAR)/$(SEMESTER)
	cp $(PDFDIR)/brief_*.pdf $(RELEASEDIR)/$(YEAR)/$(SEMESTER)/
	cp $(PDFDIR)/stundenplan_uebersicht.pdf $(RELEASEDIR)/$(YEAR)/$(SEMESTER)/
	cp $(PDFDIR)/stadtplan.pdf $(RELEASEDIR)/$(YEAR)/$(SEMESTER)/
#	svn add ../tags/$(YEAR)/$(SEMESTER)/
#	svn commit -m "released $(YEAR)$(SEMESTER)" ../tags/$(YEAR)/$(SEMESTER)/

# Dieses Target gibt allen Briefen sinnvollere Namen (die man nicht hätte
# gleich verwenden können? :D)
.PHONY: rename
rename:
	mv $(PDFDIR)/stpl_uebersicht.pdf $(PDFDIR)/stundenplan_uebersicht.pdf
	mv $(PDFDIR)/brief_bbsc.pdf $(PDFDIR)/brief_bioinfo-bsc.pdf
	mv $(PDFDIR)/brief_ibsc.pdf $(PDFDIR)/brief_informatik-bsc.pdf
	mv $(PDFDIR)/brief_imsc.pdf $(PDFDIR)/brief_informatik-msc.pdf
	mv $(PDFDIR)/brief_bmsc.pdf $(PDFDIR)/brief_bioinfo-msc.pdf
	mv $(PDFDIR)/brief_mmsc.pdf $(PDFDIR)/brief_medieninfo-msc.pdf
	mv $(PDFDIR)/brief_kmsc.pdf $(PDFDIR)/brief_kogwiss-msc.pdf
ifeq ($(SEMESTER),WS)
	mv $(PDFDIR)/brief_mbsc.pdf $(PDFDIR)/brief_medieninfo-bsc.pdf
	mv $(PDFDIR)/brief_medbsc.pdf $(PDFDIR)/brief_medizininfo-bsc.pdf
	mv $(PDFDIR)/brief_medmsc.pdf $(PDFDIR)/brief_medizininfo-msc.pdf
	mv $(PDFDIR)/brief_kbsc.pdf $(PDFDIR)/brief_kogwiss-bsc.pdf
	mv $(PDFDIR)/brief_ila.pdf $(PDFDIR)/brief_informatik-lehramt.pdf
endif

.PHONY: info
info:
	@echo 'Year: $(YEAR)'
	@echo 'Semester: $(SEMESTER) (brought forward by two months)'
	@echo 'Output directory (for auxiliary files): $(OUTDIR)'
	@echo 'PDF directory: $(PDFDIR)'
	@echo 'Release directory: $(RELEASEDIR)'
	@echo 'Plans: $(PLAENE)'
	@echo 'Sommersemester: $(SOMMERSEMESTER)'
	@echo 'Wintersemester: $(WINTERSEMESTER)'

.PHONY: help
help:
	@echo 'Building targets:'
	@echo '  default        - Build everything that is required for the current semester'
	@echo '  all            - Build everything (same as wintersemester)'
	@echo '  wintersemester - Build everything'
	@echo '  sommersemester - Build only the letters required for the sommersemester'
	@echo 'Auxiliary targets:'
	@echo '  release        - Copy the letters to $(RELEASEDIR)/$(YEAR)/$(SEMESTER)'
	@echo '  rename         - Use more meaningful names'
	@echo '  info           - Show the current configuration of the makefile'
	@echo 'Cleaning targets:'
	@echo '  clean          - Remove the $(OUTDIR)-Directory'
	@echo '  mrproper       - Remove the $(OUTDIR)- and $(PDFDIR)-Directory'
	@echo '  distclean      - Remove the $(OUTDIR)-, $(PDFDIR)- and $(RELEASEDIR)-Directory'
