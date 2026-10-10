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
  pname = "textlint-rule-date-weekday-mismatch";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-date-weekday-mismatch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KxhxJNO1QaKYY21K0/coipKYQAKWSX1kn0+yAuzRxtw=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-yGL4FSUwjOnd9oZ47rh699vadHC5pmv9wDmNtwWbIRU=";
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
    description = "Textlint rule that finds mismatches between a date and its weekday";
    homepage = "https://github.com/textlint-rule/textlint-rule-date-weekday-mismatch";
    changelog = "https://github.com/textlint-rule/textlint-rule-date-weekday-mismatch/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
