{ pkgs }:
let
  inherit (pkgs) lib;
  dirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.);
  # A plugin that takes another plugin as an argument (e.g. for its tests) must
  # get the one packaged here, not the one from nixpkgs.
  callPackage = lib.callPackageWith (pkgs // self);
  self = lib.mapAttrs (name: _: callPackage (./. + "/${name}/package.nix") { }) dirs;
in
self
