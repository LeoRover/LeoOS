{
  description = "A flake to build a basic NixOS iso";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nix-debian-image-builder.url = "github:fictionlab/nix-debian-image-builder";
    nixpkgs.follows = "nix-debian-image-builder/nixpkgs";
  };

  outputs = { nixpkgs, flake-utils, nix-debian-image-builder, ... }:
    let systems = [ "x86_64-linux" "aarch64-linux" ];
    in flake-utils.lib.eachSystem systems (system:
      let
        pkgs = (import nixpkgs) { inherit system; };

        OSName = "LeoOS";
        OSVersion = "2.5.0";

        OSImageDerivations = pkgs.callPackage ./OS-image {
          inherit OSName OSVersion;
          imageBuilder = nix-debian-image-builder.lib system;
          buildSystem = system;
        };

      in {
        packages = OSImageDerivations // {
          default = OSImageDerivations.OSLiteCompressedImage;
        };

        formatter = pkgs.nixfmt-classic;
      });
}
