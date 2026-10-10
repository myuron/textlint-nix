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
  pname = "textlint-rule-sentence-length";
  version = "5.2.1";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-sentence-length";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pGmS6KBF2L7MQsONNNhtmsVwcKOV6Py/uR6pic7b8vo=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-qhRjX++JmTGGHPzsTMG0iIF86B4ZmqgB2gtfvqI2BQc=";
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
    description = "Textlint rule that limits the maximum length of a sentence";
    homepage = "https://github.com/textlint-rule/textlint-rule-sentence-length";
    changelog = "https://github.com/textlint-rule/textlint-rule-sentence-length/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
