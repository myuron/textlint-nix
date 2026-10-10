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
  pname = "textlint-rule-no-nfd";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-no-nfd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1CIoOpMdICYS5bhwm9vfUGh6QRP6x4Z6vCcLNjqleUc=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-KBZg8c/FCyD4hR/CKaegoMMjJwd9Nth5pZfRqVAk0dw=";
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
    description = "Textlint rule that disallows NFD characters such as decomposed 濁点";
    homepage = "https://github.com/textlint-ja/textlint-rule-no-nfd";
    changelog = "https://github.com/textlint-ja/textlint-rule-no-nfd/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
