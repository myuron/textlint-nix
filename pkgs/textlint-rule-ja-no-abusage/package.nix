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
  pname = "textlint-rule-ja-no-abusage";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-ja-no-abusage";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wV3vjnGWC/1v/A+ih+g9CIdOm4zFZsoOzIxDcMc9re0=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-gCrbp6qTb3jCk43uZAOhZnwA4SqrDQMf/d4p4Fob6kE=";
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
    description = "Textlint rule that checks common misuse of Japanese words";
    homepage = "https://github.com/textlint-ja/textlint-rule-ja-no-abusage";
    changelog = "https://github.com/textlint-ja/textlint-rule-ja-no-abusage/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
