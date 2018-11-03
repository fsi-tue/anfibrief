{ nixpkgs ? <nixpkgs> }:

with import nixpkgs {};

let
  unixTime = builtins.currentTime;
  yearSeconds = 31556926;
  monthSeconds = 2629743;
  daySeconds = 86400;
  yearDelta = unixTime / yearSeconds;
  monthDelta = (unixTime - yearDelta*yearSeconds) / monthSeconds;
  dayDelta = (unixTime - yearDelta*yearSeconds - monthDelta*monthSeconds) / daySeconds;
  year = yearDelta + 1970;
  month = monthDelta + 1;
  day = dayDelta + 1;
in stdenv.mkDerivation rec {
  name = "anfibrief-${toString version}";
  version = "${toString year}-${toString month}-${toString day}";

  src = ./.;

  nativeBuildInputs = [ inkscape pdftk
    (texlive.combine {
      inherit (texlive) scheme-minimal latexmk latexconfig latex koma-script
        graphics german xcolor bera collection-fontsrecommended fontawesome
        geometry oberdiek totpages ms setspace microtype hyphenat pdfpages tools
        url hyperref;
    })
  ];

  postPatch = ''
    sed -i 's,/usr/bin/env bash,${bash}/bin/bash,' Makefile
    sed -i "s,pdf/stadtplan.pdf,$out/stadtplan.pdf," src/brief_main.tex
  '';

  buildPhase = ''
    # Workaround for Inkscape (creates some files):
    mkdir tmp-home
    export HOME=tmp-home

    # Install PDFs into $out
    export PDFDIR=$out

    # Build the PDFs
    make
  '';

  installPhase = "true"; # No need for "make install"
}
