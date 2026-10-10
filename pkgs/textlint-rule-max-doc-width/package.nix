{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-max-doc-width";
  # Upstream's tags stop at v1.3.0. This commit is the one published to npm as
  # 1.4.0.
  version = "1.4.0-unstable-2020-03-23";

  src = fetchFromGitHub {
    owner = "0Delta";
    repo = "textlint-rule-max-doc-width";
    rev = "fc437812c1f8645333db69a9528d75d2494d2436";
    hash = "sha256-1BXBplMt3p7otm7YtI+CJJnSoQwkVJCfiRWR60anlYk=";
  };

  npmDepsHash = "sha256-pMR/Zu1DFHj6wh8qrs8Nrs8uT7VJoy+LF5dJNm7c17E=";

  # The install script (node-gyp) of fsevents 1.2.12, a macOS-only optional
  # dependency of the devDependencies, does not build with the current
  # Node.js. It is only used for watching files and not needed for the build.
  npmRebuildFlags = [ "--ignore-scripts" ];

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that limits the display width of each line";
    homepage = "https://github.com/0Delta/textlint-rule-max-doc-width";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
