{
  description = "Flake for setting up Nim for PI Pico Development";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      overlays = [
        (final: prev: {
          nim-atlas = prev.nim-atlas.overrideNimAttrs {
            src = pkgs.fetchFromGitHub {
              owner = "nim-lang";
              repo = "atlas";
              rev = "60681b93af4c8914afbd8eae9fc9820ba4d198a0";
              hash = "sha256-ruevXj3MgePX4DgoWOtTdNM/I6OLvaDDgG3dCAQ/hM0=";
            };
          };
        })
      ];
      pkgs = import nixpkgs {
        inherit system;
        inherit overlays;
      };
      llvmPkgs = pkgs.llvmPackages;
      clangStdEnv = pkgs.stdenvAdapters.overrideCC llvmPkgs.stdenv (
        llvmPkgs.clang.override {
          bintools = llvmPkgs.bintools;
          gccForLibs = pkgs.gcc.cc;
        }
      );
    in {
      devShells.default = pkgs.mkShell.override {stdenv = clangStdEnv;} {
        packages = with pkgs; [
          nim
          nimble
          nim-atlas
          nimlangserver
          glibc_multi
        ];
      };
    });
}
