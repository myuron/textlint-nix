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
  pname = "textlint-rule-max-comma";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-max-comma";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Sf7ehhEOcy1HdgnIra8darkucF6RebQQV/NfJtft/DA=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-jSsVQhvmc5mJ1gh6I5UaLvdz+HpaXI0fXFX0KCh01/c=";
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
    description = "Textlint rule is that limit maximum comma(,) count of sentence";
    homepage = "https://github.com/textlint-rule/textlint-rule-max-comma";
    changelog = "https://github.com/textlint-rule/textlint-rule-max-comma/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
