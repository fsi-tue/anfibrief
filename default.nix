{ nixpkgs ? <nixpkgs> }:

with import nixpkgs {};

stdenv.mkDerivation rec {
  name = "anfibrief-${toString version}";
  # TODO: We might want to use YYYY-MM-DD
  version = builtins.currentTime;

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
