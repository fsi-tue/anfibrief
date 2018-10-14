{ nixpkgs ? <nixpkgs> }:

with import nixpkgs {};

stdenv.mkDerivation rec {
  name = "anfibrief-${toString version}";
  # TODO: We might want to use YYYY-MM-DD
  version = builtins.currentTime;

  src = ./.;

  nativeBuildInputs = [ texlive.combined.scheme-full inkscape pdftk ];

  postPatch = ''
    sed -i 's,/usr/bin/env bash,${bash}/bin/bash,' Makefile
    sed -i "s,pdf/stadtplan.pdf,$out/stadtplan.pdf," brief_main.tex
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
