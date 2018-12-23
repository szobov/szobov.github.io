{ pkgs ? import <nixpkgs>{} } :
let
  stdenv = pkgs.stdenv;
  ruby = pkgs.ruby_2_3;
in
let
  jekyll_env = pkgs.bundlerEnv {
      name = "szobov.github.io";

      inherit ruby;
      gemfile = ./Gemfile;
      lockfile = ./Gemfile.lock;
      gemset = ./gemset.nix;
  };
in
  stdenv.mkDerivation rec {
    name = "jekyll_env";
    buildInputs = [ jekyll_env ];
  }
