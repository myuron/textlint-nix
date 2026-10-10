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
  pname = "textlint-rule-no-double-negative-ja";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-no-double-negative-ja";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+3k3PIw9VwYRKL1jNP4I+BM26PXcL43U9/IkSHg0WJ4=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-t99skp7dkABsqvQnKPT4G6yFG8g4zd2z80lMp/wtKHI=";
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
    description = "Textlint rule that checks double negatives in Japanese";
    homepage = "https://github.com/textlint-ja/textlint-rule-no-double-negative-ja";
    changelog = "https://github.com/textlint-ja/textlint-rule-no-double-negative-ja/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
