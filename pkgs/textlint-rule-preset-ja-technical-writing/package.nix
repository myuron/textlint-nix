{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnInstallHook,
  nodejs,
  textlint,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "textlint-rule-preset-ja-technical-writing";
  version = "10.0.1";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-preset-ja-technical-writing";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8KoP/JagMf2kFxz8hr9e0hJH7yPukRURb48v0nPkC/8=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-jm+8XK1E60D1AgYBnlKL0fkAWnn68z2PhCK7T/XbUgk=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnInstallHook
    nodejs
  ];

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "技術文書向けのtextlintルールプリセット";
    homepage = "https://github.com/textlint-ja/textlint-rule-preset-ja-technical-writing";
    changelog = "https://github.com/textlint-ja/textlint-rule-preset-ja-technical-writing/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
