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
  pname = "textlint-rule-no-dropping-the-ra";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-no-dropping-the-ra";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ttHAeKFzczlVZrVU/C0RPVnAt4wVAU+/7+8pzrS+3+s=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-6ZrgmdgNlh3gD7lmov+bPlFstKnqpEt+yTxMCYsG99k=";
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
    description = "Textlint rule that detects ら抜き言葉";
    homepage = "https://github.com/textlint-ja/textlint-rule-no-dropping-the-ra";
    changelog = "https://github.com/textlint-ja/textlint-rule-no-dropping-the-ra/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
