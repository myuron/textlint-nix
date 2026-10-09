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
  pname = "textlint-rule-unexpanded-acronym";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-unexpanded-acronym";
    tag = finalAttrs.version;
    hash = "sha256-oUOofYfdENRQnwmBDADQgA1uGtRirqqGg8T+QA0LCXY=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-90ZONfn7CnrCsYGliF+c7Ss+SgVmaCYnaVdq3s1HdJU=";
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
    description = "Textlint rule that check unexpanded acronym";
    homepage = "https://github.com/textlint-rule/textlint-rule-unexpanded-acronym";
    changelog = "https://github.com/textlint-rule/textlint-rule-unexpanded-acronym/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
