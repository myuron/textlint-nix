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
  pname = "textlint-rule-max-ten";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-max-ten";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YEqW6dJog7cVzZKFYhlED3gEI4u6OjASHLkwjPUenoY=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-GbgB6ejiEmN4L3biFC+nTC2pReou4CABRfDc9RfBhY4=";
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
    description = "Textlint rule that limits the number of ten (、) in a sentence";
    homepage = "https://github.com/textlint-ja/textlint-rule-max-ten";
    changelog = "https://github.com/textlint-ja/textlint-rule-max-ten/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
