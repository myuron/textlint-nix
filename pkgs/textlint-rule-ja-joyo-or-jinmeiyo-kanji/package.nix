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
  pname = "textlint-rule-ja-joyo-or-jinmeiyo-kanji";
  version = "1.0.3-unstable-2021-04-24";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-ja-joyo-or-jinmeiyo-kanji";
    rev = "16ac1c286cf25694e99ae38966246f749c9e6eda";
    hash = "sha256-YtRBbalmffgGzik73rsG+20UCfJAUVZcWfIUJ8dEXBA=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-key8qLLhM4zQYiz1ZShislueHYfCXdKSDm34Q8IjnKI=";
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
    description = "Textlint rule that checks that kanji are jōyō or jinmeiyō kanji";
    homepage = "https://github.com/textlint-ja/textlint-rule-ja-joyo-or-jinmeiyo-kanji";
    license = lib.licenses.cc-by-sa-30;
    inherit (textlint.meta) platforms;
  };
})
