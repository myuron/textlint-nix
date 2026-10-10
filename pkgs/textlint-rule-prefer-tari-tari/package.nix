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
  pname = "textlint-rule-prefer-tari-tari";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-prefer-tari-tari";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jJj2cyxZisH+aT/+cd+l4GZ+Z1phM31oE5ZljdinqoA=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-zFsebqiUPDQk3YcA3g5Jl8EQEty2uFniKllNyHL6Imo=";
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
    description = "Textlint rule that checks the 「〜たり〜たりする」 expression";
    homepage = "https://github.com/textlint-ja/textlint-rule-prefer-tari-tari";
    changelog = "https://github.com/textlint-ja/textlint-rule-prefer-tari-tari/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
