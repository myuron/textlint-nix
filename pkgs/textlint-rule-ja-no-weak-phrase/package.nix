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
  pname = "textlint-rule-ja-no-weak-phrase";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-ja-no-weak-phrase";
    tag = "v${finalAttrs.version}";
    hash = "sha256-U876MBZ60xpMllUnGIAWm18A1kWOT1E4f2LMQ9jomdw=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-T1Bw1VRDk5k6ES5BAxZj1lD95naJua0+vOn8BzAskdE=";
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
    description = "Textlint rule that disallows weak phrases in Japanese";
    homepage = "https://github.com/textlint-ja/textlint-rule-ja-no-weak-phrase";
    changelog = "https://github.com/textlint-ja/textlint-rule-ja-no-weak-phrase/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
