# Anfibrief der FSI Tübingen

## Makefile

Dieses Repo besitzt ein Makefile über das ihr die Briefe noch einfacher per
Konsole erzeugen könnt. Mit `make help` erhält man eine Übersicht der Targets
(Befehle).

In der Regel sollte jedoch `make` fürs erste reichen (mit `make info` kann man
prüfen, ob das Jahr und Semester stimmt). Make sollte dann automatisch die
Briefe für das kommende Semester generieren und im Ordner "pdf" ablegen.

## HowTo Briefe updaten

Jedes Semester müssen die Briefe aktualisiert werden. Dafür müssen die
folgenden Dinge erledigt werden:

1. Termine updaten
    - Hierzu müsst ihr die Datei termine.tex öffnen und entsprechend editieren
      Termine der Fachschaft Psychologie werden mit `\ifkogni .. \fi`
      umschlossen
2. Daten in config.tex updaten
3. Stundenpläne ggf. updaten
4. Probeexemplare an die Mailingliste schicken
5. Wenn kein Einspruch kommt, Briefe an Frau Hallmayer schicken
6. Briefe releasen
    - Dazu kann hoffentlich bald `make release` genutzt werden
7. Nicht vergessen: Die Briefe auf unserer Website veröffentlichen:
   https://www.fsi.uni-tuebingen.de/erstsemester/material/start
