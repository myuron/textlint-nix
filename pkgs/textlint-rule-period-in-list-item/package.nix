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
  pname = "textlint-rule-period-in-list-item";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-period-in-list-item";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hAkueH5q5s0kmvKZiOrCxtfmoHtHH0U8cVLhQ7eoqT0=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-4tVTR/Wpcr/nJrBhqV3AowwcUiFNiuohyKn6yQvorvc=";
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
    description = "Textlint rule that check with or without period in list item";
    homepage = "https://github.com/textlint-rule/textlint-rule-period-in-list-item";
    changelog = "https://github.com/textlint-rule/textlint-rule-period-in-list-item/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
