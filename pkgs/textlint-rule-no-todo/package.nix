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
  pname = "textlint-rule-no-todo";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-no-todo";
    tag = finalAttrs.version;
    hash = "sha256-+m+iiijZjayNZVyPA5zKU3fLR2Os0zWeu9gSzoBjkhk=";
  };

  # Some entries of yarn.lock are resolved over plain http, which fetchYarnDeps
  # cannot download. The fetcher gets the same postPatch, so that its copy of
  # yarn.lock matches the one yarnConfigHook sees.
  postPatch = ''
    substituteInPlace yarn.lock \
      --replace-fail "http://registry.npmjs.org/" "https://registry.npmjs.org/"
  '';

  yarnOfflineCache = fetchYarnDeps {
    inherit (finalAttrs) src postPatch;
    hash = "sha256-ifBt5QsjvwpbKEOh0OyEDHwBDQFqkssLThWrUqAN9KE=";
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
    description = "Textlint rule that warns about TODO text";
    homepage = "https://github.com/textlint-rule/textlint-rule-no-todo";
    changelog = "https://github.com/textlint-rule/textlint-rule-no-todo/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
