{
  description = "A flake to build a basic NixOS iso";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = (import nixpkgs) {
        inherit system;
      };

      OSName = "LeoOS";
      OSVersion = "0.0.0";

      OSImage = pkgs.callPackage ./OS-image { inherit OSName OSVersion; };

    in {
      packages.${system} = { default = OSImage; };

      formatter.${system} = pkgs.buildPackages.nixfmt-classic;
    };
}
