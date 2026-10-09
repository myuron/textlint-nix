{ pkgs, self }:
let
  inherit (pkgs) lib;
  plugins = import ../pkgs { inherit pkgs; };

  # Every plugin under pkgs/ must ship a test. Checked here, not in pkgs/, so
  # that only `nix flake check` fails and consumers of the packages do not.
  testsOf =
    name: plugin:
    let
      tests = plugin.passthru.tests or { };
    in
    if tests == { } then
      throw ''
        Plugin "${name}" has no tests: passthru.tests is missing or empty.
        Define it in pkgs/${name}/package.nix, e.g.

          passthru.tests = textlint.testPackages {
            rule = finalAttrs.finalPackage;
            testFile = ./test.md;
          };

        and add pkgs/${name}/test.md, a text that violates the rule.
      ''
    else
      tests;
in
{
  statix = pkgs.runCommand "statix-check" { nativeBuildInputs = [ pkgs.statix ]; } ''
    statix check ${self}
    touch $out
  '';
  deadnix = pkgs.runCommand "deadnix-check" { nativeBuildInputs = [ pkgs.deadnix ]; } ''
    deadnix --fail ${self}
    touch $out
  '';
  mkTextlint = import ./mk-textlint.nix { inherit pkgs self; };
}
// lib.concatMapAttrs testsOf plugins
