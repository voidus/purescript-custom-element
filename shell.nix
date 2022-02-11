{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShellNoCC {
  buildInputs = with pkgs; [
    purescript
    spago
    nodePackages.eslint
  ];
}
