{
  description = "Example project using textlint-nix";

  inputs = {
    textlint-nix.url = "path:..";
    nixpkgs.follows = "textlint-nix/nixpkgs";
  };

  outputs =
    { nixpkgs, textlint-nix, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = [
            (textlint-nix.lib.mkTextlint {
              inherit pkgs;
              plugins.textlint-rule-no-hankaku-kana.enable = true;
              plugins.textlint-rule-max-comma.enable = true;
            })
          ];
        };
      });
    };
}
