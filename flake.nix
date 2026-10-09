{
  description = "Manage textlint and its plugins with Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = [
            pkgs.nixfmt-tree
            pkgs.statix
            pkgs.deadnix
          ];
        };
      });

      lib = import ./lib;

      packages = forAllSystems (pkgs: import ./pkgs { inherit pkgs; });

      checks = forAllSystems (pkgs: import ./tests { inherit pkgs self; });
    };
}
