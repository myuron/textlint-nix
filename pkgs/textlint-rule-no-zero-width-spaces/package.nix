{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  nodejs,
  textlint,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "textlint-rule-no-zero-width-spaces";
  # Upstream has no tags. package.json at this commit says 1.0.1, and the commit
  # is from the same day as the 1.0.1 release on npm.
  version = "1.0.1-unstable-2021-05-01";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-no-zero-width-spaces";
    rev = "a2ba0ca70dafffd6affc4021f04e124d70fe809d";
    hash = "sha256-o/OTYmgXFxy7IN4Cphq6PUGc0QFI+QN/twahm0AomCk=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-lXamiRP+0zsDcgLWmYSS7PaIPu9LwO7Sz4WLxZKgPsQ=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that disallows zero width spaces";
    homepage = "https://github.com/textlint-rule/textlint-rule-no-zero-width-spaces";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
