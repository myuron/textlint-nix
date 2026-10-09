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
  pname = "textlint-rule-write-good";
  version = "2.0.0-unstable-2024-05-02";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-write-good";
    rev = "586afa0989ae9ac8a93436f58a24d99afe1cac21";
    hash = "sha256-ghEmWkwGVvLMy6Gf7IrariDRNfuNBc9EVOQz5w38g0I=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-J02MoKPEYtehQMSaOR1Ytfme1ffgHbQcNnEENeTaxaA=";
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
    description = "Textlint rule to check your English styles with write-good";
    homepage = "https://github.com/textlint-rule/textlint-rule-write-good";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
