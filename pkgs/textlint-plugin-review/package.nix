{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
  textlint-rule-max-comma,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-plugin-review";
  version = "0.4.1-unstable-2020-02-15";

  # Upstream has no v0.4.1 tag. Pin the commit that corresponds to npm 0.4.1.
  src = fetchFromGitHub {
    owner = "orangain";
    repo = "textlint-plugin-review";
    rev = "3707f4bd82e50ce92822961284c017990135c29a";
    hash = "sha256-waRte5ORv+HfdTjwBpz/gQMB/NqIWD5EbOI0qtA0RqQ=";
  };

  npmDepsHash = "sha256-eF1SLx44FZeD7BsZ+dJPh50ixTM5kQvzgEjgxSrdwps=";

  # The install script (node-pre-gyp) of fsevents 1.2.9, a macOS-only optional
  # dependency of the devDependencies, does not build with the current
  # Node.js. It is only used for watching files and not needed for the build.
  npmRebuildFlags = [ "--ignore-scripts" ];

  passthru.tests = textlint.testPackages {
    inherit (finalAttrs) pname;
    rule = textlint-rule-max-comma;
    plugin = finalAttrs.finalPackage;
    testFile = ./test.re;
  };

  meta = {
    description = "Textlint Re:VIEW processor plugin";
    homepage = "https://github.com/orangain/textlint-plugin-review";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
