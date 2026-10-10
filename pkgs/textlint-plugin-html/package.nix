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
  textlint-rule-max-comma,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "textlint-plugin-html";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "textlint";
    repo = "textlint-plugin-html";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/G1broo4QJHYoBXUHZzK8DLDxKFHpHVWDmkEExkFEPk=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-poZsWLtMH6Gy3tcWLhuv5c65AU0KVoMJD62m5r+ZLu4=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  passthru.tests = textlint.testPackages {
    inherit (finalAttrs) pname;
    rule = textlint-rule-max-comma;
    plugin = finalAttrs.finalPackage;
    testFile = ./test.html;
  };

  meta = {
    description = "Textlint HTML plugin";
    homepage = "https://github.com/textlint/textlint-plugin-html";
    changelog = "https://github.com/textlint/textlint-plugin-html/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
