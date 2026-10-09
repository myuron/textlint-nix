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
  pname = "textlint-rule-en-max-word-count";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-en-max-word-count";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZZWN0PVHQBHcvJ53jDtD/6wLxBYmSHO7OXb5UQQAmyc=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-3sEbvIfSaMz9pJalEKs7y05OVh+cKDg9jfLYmVyS53M=";
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
    description = "Textlint rule that specify the maximum word count of a sentence";
    homepage = "https://github.com/textlint-rule/textlint-rule-en-max-word-count";
    changelog = "https://github.com/textlint-rule/textlint-rule-en-max-word-count/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
