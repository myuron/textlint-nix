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
  pname = "textlint-rule-en-capitalization";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-en-capitalization";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gTwO6C/Sniry4P94HCoJWPulgQIMwa1Nwk7ucpOkSGM=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-fh1gwpz4bZVejiZE74/kRyTOYyd3z4YdoGHjiTUEg+U=";
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
    description = "Textlint rule that checks capitalization in English text";
    homepage = "https://github.com/textlint-rule/textlint-rule-en-capitalization";
    changelog = "https://github.com/textlint-rule/textlint-rule-en-capitalization/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
