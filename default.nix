{ nixpkgs ? <nixpkgs>
# To reproduce a build via .github/scripts/reproduce.py:
, date ? null
, srcUrl ? null
}:

with import nixpkgs {};

stdenv.mkDerivation rec {
  name = "anfibrief-${version}";
  version = if (date != null)
    then date
    else lib.fileContents
      (runCommand "anfibrief-date" {} "date --utc +'%F' > $out");

  src = if srcUrl != null
    then fetchTarball srcUrl
    else lib.cleanSource ./.;

  nativeBuildInputs = [ inkscape pdftk
    (texlive.combine {
      inherit (texlive) scheme-minimal latexmk latexconfig latex koma-script
        graphics german xcolor bera collection-fontsrecommended fontawesome
        geometry oberdiek totpages ms setspace microtype hyphenat pdfpages tools
        url hyperref babel babel-german hyphen-german hycolor atveryend
        epstopdf-pkg pdflscape l3kernel l3packages;
    })
  ];

  postPatch = ''
    # Set SOURCE_DATE_EPOCH to make the build reproducible:
    export SOURCE_DATE_EPOCH="$(date --date=$version +'%s')"
    # Override the LaTeX values for \today:
    sed -i "s,\\year=\\year,\\year=$(date --date=$version +'%Y')," src/env.tex
    sed -i "s,\\month=\\month,\\month=$(date --date=$version +'%m')," src/env.tex
    sed -i "s,\\day=\\day,\\day=$(date --date=$version +'%d')," src/env.tex
    # Changes for the Nix build:
    sed -i 's,/usr/bin/env bash,${bash}/bin/bash,' Makefile
  '';

  buildPhase = ''
    # Workaround for Inkscape (creates some files):
    mkdir tmp-home
    export HOME=tmp-home

    # In case $src already contains files in out/ and pdf/:
    make distclean

    # Build the PDFs
    make
  '';

  installPhase = ''
    mkdir $out
    cp pdf/* $out
  '';
}
