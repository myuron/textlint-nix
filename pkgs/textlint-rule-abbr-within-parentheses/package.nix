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
  pname = "textlint-rule-abbr-within-parentheses";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "azu";
    repo = "textlint-rule-abbr-within-parentheses";
    tag = finalAttrs.version;
    hash = "sha256-CBrf7WtvywDmtuSyxkDtAyjmrj7KS3TQLSsNfMxeWXw=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-N4tnja6qTo7jtn7Dh4TwBUCUKfbIbHvdZ7aeJcE+NlU=";
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
    description = "Textlint rule check if write abbreviations within parentheses";
    homepage = "https://github.com/azu/textlint-rule-abbr-within-parentheses";
    changelog = "https://github.com/azu/textlint-rule-abbr-within-parentheses/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
