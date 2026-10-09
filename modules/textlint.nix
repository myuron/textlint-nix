{
  lib,
  pkgs,
  config,
  ...
}:
let
  available = import ../pkgs { inherit pkgs; };
in
{
  options = {
    plugins = lib.mapAttrs (name: _: {
      enable = lib.mkEnableOption name;
    }) available;

    finalPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      description = "textlint wrapped with the enabled plugins.";
    };
  };

  config.finalPackage = pkgs.textlint.withPackages (
    lib.attrValues (lib.filterAttrs (name: _: config.plugins.${name}.enable) available)
  );
}
