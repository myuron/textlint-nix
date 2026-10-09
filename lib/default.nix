{
  mkTextlint =
    { pkgs, ... }@args:
    (pkgs.lib.evalModules {
      specialArgs = { inherit pkgs; };
      modules = [
        ../modules/textlint.nix
        (removeAttrs args [ "pkgs" ])
      ];
    }).config.finalPackage;
}
