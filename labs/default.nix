{ pkgs ? import <nixpkgs> { } }:

pkgs.buildGoModule rec {
  pname = "app";
  version = "1.0.0";

  src = ./.;

  vendorHash = null;
  subPackages = [ "." ];
  ldflags = [
    "-s"
    "-w"
    "-buildid="
  ];

  meta = with pkgs.lib; {
    description = "Small Go application used in Lab 11 for reproducible builds with Nix";
    license = licenses.mit;
    mainProgram = "app";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
