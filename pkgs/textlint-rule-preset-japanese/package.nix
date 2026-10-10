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
  pname = "textlint-rule-preset-japanese";
  version = "10.0.4";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-preset-japanese";
    tag = "v${finalAttrs.version}";
    hash = "sha256-i7DVkSLGEVk+asTS2obNtW0OtZq8vPXkwC0JeEsGlh8=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-mFZLBtG3Y/etLGf+dhyPbhxlQnoMhV845AKhaRu8iqk=";
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
    description = "Textlint rule preset for Japanese";
    homepage = "https://github.com/textlint-ja/textlint-rule-preset-japanese";
    changelog = "https://github.com/textlint-ja/textlint-rule-preset-japanese/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
