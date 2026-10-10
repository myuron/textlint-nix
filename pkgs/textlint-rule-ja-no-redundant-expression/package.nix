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
  pname = "textlint-rule-ja-no-redundant-expression";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-ja-no-redundant-expression";
    tag = "v${finalAttrs.version}";
    hash = "sha256-03CfPwlevBT3GB/ssCc3rb3K1U8RQSbT1GLIvYzajHs=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-0vidsVVjNv5Npn+PrJUDIjRF+ILmTb+Hp+6+V0D2vlM=";
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
    description = "Textlint rule that disallows redundant expressions in Japanese";
    homepage = "https://github.com/textlint-ja/textlint-rule-ja-no-redundant-expression";
    changelog = "https://github.com/textlint-ja/textlint-rule-ja-no-redundant-expression/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
