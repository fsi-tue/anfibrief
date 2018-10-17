# Anfibrief der FSI Tübingen

## Makefile

Dieses Repo besitzt ein Makefile über das ihr die Briefe noch einfacher per
Konsole erzeugen könnt. Mit `make help` erhält man eine Übersicht der Targets
(Befehle).

In der Regel sollte jedoch `make` fürs erste reichen (mit `make info` kann man
prüfen, ob das Jahr und Semester stimmt). Make sollte dann automatisch die
Briefe für das kommende Semester generieren und im Ordner "pdf" ablegen.

### Voraussetzungen
- Ihr benötigt ein Linux-System oder einen Mac. Sorry.
- Inkscape muss installiert sein.

## HowTo Briefe updaten

Jedes Semester müssen die Briefe aktualisiert werden. Dafür müssen die
folgenden Dinge erledigt werden:

1. Termine updaten
    - Hierzu müsst ihr die Datei termine.tex öffnen und entsprechend editieren
      Termine der Fachschaft Psychologie werden mit `\ifkogwiss .. \fi`
      umschlossen
    - Es gibt desweiteren noch das Flag `\ifmaster ... \fi`, mit dem man Termine nur für alle Masterstudiengänge gültig machen kann.
2. Daten in config.tex updaten
3. Stundenpläne ggf. updaten
4. Probeexemplare an die Mailingliste schicken
5. Wenn kein Einspruch kommt, Briefe an Frau Hallmayer schicken
6. Briefe releasen
    - Dazu kann hoffentlich bald `make release` genutzt werden
7. Nicht vergessen: Die Briefe auf unserer Website veröffentlichen:
   https://www.fsi.uni-tuebingen.de/erstsemester/material/start

## Wo ist was?
Die Briefe der einzelnen Studiengänge setzen sich zusammen aus:
- `media/anfibrief.lco`, diese Datei defineirt den Briefkopf und das Seitenlayout sowie die Fußzeile.
- `src/config.tex`, hier werden grundsätzliche Infos die in jedem Brief vorkommen gesetzt, z.B. Info- und Mathe-Profs sowie der Preis des Semestertickets.
- `src/brief_main.tex`, hier wird das Hauptdokument definert und die einzelnen Abschnitte werden eingebunden.
- `src/brief_init.tex`, hier werden die `if`-Statements für die einzelnen Briefe definiert und auf false gesetzt. **Diese Datei nicht verändern!** (Es sei denn, ihr legt einen neuen Studiengang an.)
- `briefe/brief_<studiengang>.tex`, hier werden im Prinzip nur Variablen gesetzt, die die Platzhalter in der Datei `brief_main.tex` ersetzen.
- `stundenplaene/stpl_<studiengang>.tex`, hier wird die Sektion "Das erwartet dich im Studium" definiert, wichtig ist hier vor allem die Tabelle mit dem Stundenplan.

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

- Wichtig: Der Stadtplan wird automatisiert in eine PDF umgewandelt und an die Briefe gehängt. Den Stadtplan nur mit Inkscape bearbeiten, Illustrator o.ä. sorgen für seltsame Fehler im Makefile.
