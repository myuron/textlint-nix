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
  pname = "textlint-rule-ja-no-mixed-period";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-ja-no-mixed-period";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xncJp3X8ek+FxHyF1KjLleSp60f+JU3OpBBHVrMPYJs=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-0n5c0gZ4xQ7g9Cl4mpUWM6xYvy6H2CrPr0sbDsdINSo=";
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
    description = "Textlint rule that checks for missing or inconsistent periods (。) at the end of sentences";
    homepage = "https://github.com/textlint-ja/textlint-rule-ja-no-mixed-period";
    changelog = "https://github.com/textlint-ja/textlint-rule-ja-no-mixed-period/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
