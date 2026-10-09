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
  pname = "textlint-rule-no-start-duplicated-conjunction";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-no-start-duplicated-conjunction";
    tag = finalAttrs.version;
    hash = "sha256-DtuCkHy440j2VI/JDJGrW2M8alQ8pxllfIZfB4+9z3U=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-+3SJQgOG5bYSmNWbxsFNEEtKtCg8V04MIk6FhHwOZMo=";
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
    description = "Textlint rule that check no start with duplicated conjunction";
    homepage = "https://github.com/textlint-rule/textlint-rule-no-start-duplicated-conjunction";
    changelog = "https://github.com/textlint-rule/textlint-rule-no-start-duplicated-conjunction/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
