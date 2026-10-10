{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  nodejs,
  jq,
  textlint,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "textlint-rule-rousseau";
  version = "1.4.8";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-rousseau";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jEuCP8nuF8hCq1VeirrPznQ9WWtHYeV1FmyyNQh5/48=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-FBUF2uau8FlWJGfPzqlKpvTIhFDr1+AmGqeRHiSruws=";
  };

  # textlint-rule-helper 2.2.1 requires @textlint/ast-node-types without
  # declaring it. A production install only has it nested under
  # textlint-util-to-string, so the rule fails to load. Add the version
  # yarn.lock already has to dependencies to keep it at the top level.
  postPatch = ''
    jq '.dependencies."@textlint/ast-node-types" = "^12.2.1"' package.json > package.json.tmp
    mv package.json.tmp package.json
  '';

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
    jq
  ];

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule to check English sentences with rousseau";
    homepage = "https://github.com/textlint-rule/textlint-rule-rousseau";
    changelog = "https://github.com/textlint-rule/textlint-rule-rousseau/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
