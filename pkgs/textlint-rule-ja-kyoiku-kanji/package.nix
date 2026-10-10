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
  pname = "textlint-rule-ja-kyoiku-kanji";
  version = "1.0.2-unstable-2021-04-24";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-ja-kyoiku-kanji";
    rev = "56c1d6655f26e627c0091deb3a2426f6024cfd80";
    hash = "sha256-/je4k4Mo/bstb1ykabMaM8W78stfRxyia/3t65z2IdI=";
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
    description = "Textlint rule that checks that kanji are kyōiku kanji";
    homepage = "https://github.com/textlint-ja/textlint-rule-ja-kyoiku-kanji";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
