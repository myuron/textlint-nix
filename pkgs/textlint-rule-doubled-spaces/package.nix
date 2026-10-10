{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-doubled-spaces";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "iwamatsu0430";
    repo = "textlint-rule-doubled-spaces";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wzx7ckkC7c0n64gxHqpumWEFBJlPfrI9FeipsOy6U2o=";
  };

  npmDepsHash = "sha256-3OpkC6Zmq69x1iHxXxv4cx1V9pHhFZxaKdwd+UP4d6E=";

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that checks doubled spaces in a sentence";
    homepage = "https://github.com/iwamatsu0430/textlint-rule-doubled-spaces";
    changelog = "https://github.com/iwamatsu0430/textlint-rule-doubled-spaces/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
