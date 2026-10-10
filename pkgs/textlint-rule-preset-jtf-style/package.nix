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
  pname = "textlint-rule-preset-jtf-style";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-preset-JTF-style";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iI3sK59NOeXrbN+ROqN+68UnkWOureHuPfsNHuiudzM=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-R6Bnay2r1VJ9NKIjvj80r4Jw29nv6lV8+r9N0QTrSTE=";
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
    description = "JTF Style Guide for Translators Working into Japanese for textlint";
    homepage = "https://github.com/textlint-ja/textlint-rule-preset-JTF-style";
    changelog = "https://github.com/textlint-ja/textlint-rule-preset-JTF-style/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
