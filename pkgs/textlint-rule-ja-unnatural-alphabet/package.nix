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
  pname = "textlint-rule-ja-unnatural-alphabet";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-ja-unnatural-alphabet";
    tag = finalAttrs.version;
    hash = "sha256-iWQ0qOIn4acIaMae2QkO1i5BDL7L3Q65cjojgd+/CAo=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-atYH5D6b2EanIXwl9/WpZdrj79a0p7/QioTwhAJX/ok=";
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
    description = "Textlint rule that detects unnatural alphabets in Japanese text";
    homepage = "https://github.com/textlint-ja/textlint-rule-ja-unnatural-alphabet";
    changelog = "https://github.com/textlint-ja/textlint-rule-ja-unnatural-alphabet/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
