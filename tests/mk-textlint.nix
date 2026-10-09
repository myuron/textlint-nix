# Wiring test for the module: enables two plugins packaged under pkgs/ and
# checks that both report. Also checks that a plugin that exists only in the
# given pkgs (i.e. only in nixpkgs) is not exposed as an option. Per-plugin
# tests live next to each pkgs/<name>/package.nix as passthru.tests.
{ pkgs, self }:
let
  inherit (pkgs) lib;
  textlint = self.lib.mkTextlint {
    inherit pkgs;
    plugins.textlint-rule-max-comma.enable = true;
    plugins.textlint-rule-no-hankaku-kana.enable = true;
  };
  # Every plugin in the locked nixpkgs is also packaged under pkgs/, so no real
  # name is nixpkgs-only. Fake one instead of relying on what nixpkgs ships.
  nixpkgsOnly =
    builtins.tryEval
      (self.lib.mkTextlint {
        pkgs = pkgs // {
          textlint-rule-only-in-nixpkgs = pkgs.emptyDirectory;
        };
        plugins.textlint-rule-only-in-nixpkgs.enable = true;
      }).drvPath;
in
assert lib.assertMsg (!nixpkgsOnly.success) "plugins from nixpkgs must not be exposed as options";
pkgs.runCommand "mk-textlint-check" { nativeBuildInputs = [ textlint ]; } ''
  textlint --rule max-comma --rule no-hankaku-kana ${./mk-textlint.md} > result.txt || true
  cat result.txt
  grep max-comma result.txt
  grep no-hankaku-kana result.txt
  touch $out
''
