{ pkgs ? import (builtins.fetchTarball {
    name = "nixpkgs-2020-02-11";
    url = https://github.com/NixOS/nixpkgs/archive/23.11.tar.gz;
    sha256 = "1ndiv385w1qyb3b18vw13991fzb9wg4cl21wglk89grsfsnra41k";
  }) {}
}:
let
  stdenv = pkgs.stdenv;
  ruby = pkgs.ruby;
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
    buildInputs = [ jekyll_env jekyll_env.wrappedRuby utils ];

    shellHook = ''
      jekyll server --drafts
    '';
  }
