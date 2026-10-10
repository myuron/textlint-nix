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
  pname = "textlint-rule-ja-no-inappropriate-words";
  version = "2.0.0-unstable-2021-04-24";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-ja-no-inappropriate-words";
    rev = "a36c03429877a1d3b83cce28b229b0ab31b7e1c8";
    hash = "sha256-YdVQdwgOrd+nW4/eeQmVWu+h0QuW5BRG2z08zMRRPNA=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-uIJHhz3NDMFNi8ZwN8Y9GQsIba1ppXkY5F7JgB4GUFQ=";
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
    description = "Textlint rule that checks inappropriate Japanese words";
    homepage = "https://github.com/textlint-ja/textlint-rule-ja-no-inappropriate-words";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
