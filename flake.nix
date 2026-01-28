{
  description = "A flake to build a basic NixOS iso";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    let systems = [ "x86_64-linux" "aarch64-linux" ];
    in flake-utils.lib.eachSystem systems (system:
      let
        pkgs = (import nixpkgs) { inherit system; };

        OSName = "LeoOS";
        OSVersion = "2.4.0-humble-1";

        OSImageDerivations = pkgs.callPackage ./OS-image {
          inherit OSName OSVersion;
          buildSystem = system;
        };

      in {
        packages = OSImageDerivations // {
          default = OSImageDerivations.OSLiteCompressedImage;
        };

        formatter = pkgs.nixfmt-classic;
      });
}
