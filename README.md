# Anfibrief der FSI Tübingen

## Makefile

Dieses Repo besitzt ein Makefile über das ihr die Briefe noch einfacher per
Konsole erzeugen könnt. Mit `make help` erhält man eine Übersicht der Targets
(Befehle).

In der Regel sollte jedoch `make` fürs erste reichen (mit `make info` kann man
prüfen, ob das Jahr und Semester stimmt). Make sollte dann automatisch die
Briefe für das kommende Semester generieren und im Ordner `pdf` ablegen.

### Voraussetzungen
- Ihr benötigt ein Linux-System oder einen Mac. Sorry.
- Inkscape und PDFTK müssen installiert sein. Ubuntu/Debian: `sudo apt install inkscape pdftk`
- Auf Arch/Manjaro müssen zudem java-commons-lang und bcprov installiert sein: `sudo pacman -S inkscape pdftk java-commons-lang bcprov`
- Zum benutzen der Makefile müssen auf allen Distributionen die Pakete `make` und `latexmk` installiert sein

### TexLive-Pakete
#### Archlinux und Derivate (Stand: August 2024)
<!-- - texlive-bin (automatisch als Abhängigkeit der Unteren) -->
<!-- - texlive-core (automatisch als Abhängigkeit der Unteren) -->
- texlive-fontsextra
- texlive-latexextra
- texlive-binextra
- texlive-langgerman
- texlive-eurosym (bzw. texlive-fontsrecommended)
```sh
sudo pacman -S texlive-fontsextra texlive-latexextra texlive-binextra texlive-langgerman texlive-eurosym
```


#### Ubuntu, Debian und Derivate
- tex-common (automatisch als Abhängigkeit der Unteren)
- texlive-base (automatisch als Abhängigkeit der Unteren)
- texlive-binaries (automatisch als Abhängigkeit der Unteren)
- texlive-latex-base  (automatisch als Abhängigkeit der Unteren)
- texlive-latex-recommended
- texlive-lang-german
- texlive-fonts-extra

## HowTo Briefe updaten

Jedes Semester müssen die Briefe aktualisiert werden. Dafür müssen die
folgenden Dinge erledigt werden:

0. Informationen sammeln:
    - Mathe Vorkurs (Wann, Anmeldeschluss). Falls noch nirgends zu finden ist wer den macht, dann Britta Dorn fragen.
    - Informatik Vorkurs für BioInfos bei Philipp Thiel (Wann, Anmeldeschluss)

1. Termine updaten
    - Hierzu müsst ihr die Datei termine.tex öffnen und entsprechend editieren.
      Termine der Fachschaft Psychologie werden mit `\ifkogwiss .. \fi`
      umschlossen.
    - Es gibt desweiteren noch das Flag `\ifmaster ... \fi`, mit dem man Termine
      nur für alle Masterstudiengänge gültig machen kann.

2. Daten in `src/config.tex` updaten
3. Stundenpläne ggf. updaten, (siehe Modulhandbuch / Alma)
4. Alle Stellen überprüfen, die mit `TODO` markiert sind (`grep -R TODO`) und ggf. updaten
5. Probeexemplare an die Mailingliste schicken
6. Wenn kein Einspruch kommt, Briefe an Verena Seibold schicken
7. Briefe releasen
    - Dazu einfach auf den `master`-Branch von
      https://github.com/fsi-tue/anfibrief pushen, die PDFs werden dann
      automatisch generiert und veröffentlicht
      ([Index](https://teri.fsi.uni-tuebingen.de/anfibrief/)).
    - Das Ergebnis bitte kurz prüfen.

### HowTo WS 2022/2023
- Die POs haben sich geändet, die meisten meisten Änderungen sind im Anfibrief von SoSe 2022 schon drinn.

## Wo ist was?
Die Briefe der einzelnen Studiengänge setzen sich zusammen aus:
- `media/anfibrief.lco`, diese Datei definiert den Briefkopf und das
  Seitenlayout sowie die Fußzeile.
- `src/config.tex`, hier werden grundsätzliche Infos die in jedem Brief
  vorkommen gesetzt, z.B. Info- und Mathe-Profs sowie der Preis des
  Semestertickets, Anmeldeschluss für Vorkurse
- `src/brief_main.tex`, hier wird das Hauptdokument definert und die einzelnen
  Abschnitte werden eingebunden.
- `src/brief_init.tex`, hier werden die `if`-Statements für die einzelnen Briefe
  definiert und auf false gesetzt. **Diese Datei nicht verändern!** (Es sei
  denn, ihr legt einen neuen Studiengang an.)
- `briefe/brief_<studiengang>.tex`, hier werden im Prinzip nur Variablen
  gesetzt, die die Platzhalter in der Datei `brief_main.tex` ersetzen.
- `stundenplaene/stpl_<studiengang>.tex`, hier wird die Sektion "Das erwartet
  dich im Studium" definiert, wichtig ist hier vor allem die Tabelle mit dem
  Stundenplan.

|Überschrift|Datei|
|-----------|-----|
|"Dein Terminkalender für die ersten Tage"|`src/termine.tex`|
|"Das erwartet dich im Studium"|`stundenplaene/stpl_<studiengang>.tex`|
|"Die Anfangszeiten und Orte"|`src/misc.tex`|
|"Die Informatik-Vorlesung"|`src/misc.tex`|
|"Mailinglisten"|`src/mailinglisten.tex`|
|"Verkehr in Tübingen"|`src/tuebingen.tex`|
|"Wohnen in Tübingen"|`src/tuebingen.tex`|
|Stadtplan|`media/stadtplan.svg`|

- Wichtig: Der Stadtplan wird automatisiert in eine PDF umgewandelt und an die
  Briefe gehängt. Den Stadtplan nur mit Inkscape bearbeiten, Illustrator o.ä.
  sorgen für seltsame Fehler im Makefile.

## If-Else-Trickserei
An vielen Stellen, vor allem bei den Terminen, können unterschiedliche Texte notwendig sein, da z.B. Anfangszeiten unterschiedlich sind oder der Text auf Englisch verfasst werden muss. Wir haben dazu für Winter- und Sommersemester sowie jeden Studiengang eine if-Konstruktion eingebaut, mit der sich die Dokumente entsprechend verzweigen lassen:

|Boolean|Befehl|
|-------|------|
|Sommersemester?|`\ifsommersemester`|
|Wintersemester?|`\ifwintersemester`|
|Bachelor?|`\ifbachelor`|
|Master?|`\ifmaster`|
|Info?|`\ifinfo`|
|Bioinfo?|`\ifbinfo`|
|Medieninfo?|`\ifmedien`|
|Kogni?|`\ifkogwiss`|
|Lehramt?|`\iflehramt`|
|Medizininfo?|`\ifmedinfo`|
|Machine Learning?|`\ifml`|

Benutzung wie folgt:
```latex
\ifsommersemester
    \ifbachelor
        \ifbinfo
            Dieser Text erscheint nur im Bachelor Bioinformatik-Brief und wenn der Brief fürs Sommersemester kompiliert wird.
         \fi
    \fi
\fi
```
Ganz wichtig: **Alle** ifs immer mit `\fi` schließen, sonst fliegt euch das Dokument um die Ohren.

## Private Subversion history

FSI members can also obtain the private history from Subversion by issuing the
following 3 commands inside of this repository (`git-svn` must be installed):

```bash
git svn init --stdlayout --prefix=svn/ https://projects.fsi.uni-tuebingen.de/svn/anfibrief
# The following requires an FSI SVN account and will take quite a few minutes:
git svn fetch
# Last revision:
# r262 = b355af9fa399ff559e379a4f1ffb8d37d6ee2069 (refs/remotes/svn/trunk)
git replace --graft 04ba800db821516ff044d0e7d72ca32c82196d91 b355af9fa399ff559e379a4f1ffb8d37d6ee2069
```

Git can then be used exactly like before but `git-log`, `git-blame`, etc. will
be aware of the full history.
