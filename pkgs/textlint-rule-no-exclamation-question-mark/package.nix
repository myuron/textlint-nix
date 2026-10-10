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
  pname = "textlint-rule-no-exclamation-question-mark";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-no-exclamation-question-mark";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5hghTY3091j41M7KpW6THAHmiVgteI1Ul9jfIriujVQ=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-5OMQNqD1/OuWl3KzQX4Y/CKY+rnEPqove1O0W7HQbPQ=";
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
    description = "Textlint rule that disallows exclamation and question marks";
    homepage = "https://github.com/textlint-rule/textlint-rule-no-exclamation-question-mark";
    changelog = "https://github.com/textlint-rule/textlint-rule-no-exclamation-question-mark/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
