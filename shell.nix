{ pkgs ? import <nixpkgs>{} } :
let
  stdenv = pkgs.stdenv;
  ruby = pkgs.ruby_2_6;
in
let

  utils = with pkgs; [
      bundix
      pngquant
      imagemagick
  ];


  jekyll_env = pkgs.bundlerEnv {
      name = "jekill_env";

      inherit ruby;
      gemfile = ./Gemfile;
      lockfile = ./Gemfile.lock;
      gemset = ./gemset.nix;
  };
in
  stdenv.mkDerivation rec {
    name = "szobov.github.io";
    buildInputs = [ jekyll_env utils ];

    shellHook = ''
      jekyll server --drafts
    '';
  }
