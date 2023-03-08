let
  pkgs = import <nixpkgs> {};
  cache = pkgs.makeFontsCache {
    fontDirectories = pkgs.texlive.stix2-otf.pkgs;
  };
  config = pkgs.writeText "fonts.conf" ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <dir>${builtins.elemAt pkgs.texlive.stix2-otf.pkgs 0}</dir>
      <cachedir>${cache}</cachedir>
    </fontconfig>
  '';
in

with pkgs;

stdenv.mkDerivation {
  name = "paper";
  src = ./src;

  TEXMFVAR = "/tmp/texmf";
  SOURCE_DATE_EPOCH = builtins.currentTime;

  preBuild = ''
    mkdir -p $TEXMFVAR
  '';

  installPhase = ''
    mkdir -p $out
    cp paper.pdf $out
  '';

  
  FONTCONFIG_FILE = config;

  buildInputs = [
    fontconfig
    (texlive.combine {
      inherit (texlive) scheme-small luatex biblatex latexmk stix2-otf biber unicode-math lualatex-math tcolorbox environ mathdots;
    })
  ];
}
