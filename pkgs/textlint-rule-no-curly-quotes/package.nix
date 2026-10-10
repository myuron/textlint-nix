{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-no-curly-quotes";
  version = "1.0.0-unstable-2024-07-07";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "aborazmeh";
    repo = "textlint-rule-no-curly-quotes";
    rev = "9d16590cc39c1e2ab8305e2eb9d47b95c0ade2e6";
    hash = "sha256-xKFDRe13J8do+3ThmkKc/quSvjomc6mUlKvW+RITtJU=";
  };

  npmDepsHash = "sha256-Wc8qvORZhCUtIX70zk8r40sso5PJDC53ZbY7qBcQ0ks=";

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that disallows curly quotation marks";
    homepage = "https://github.com/aborazmeh/textlint-rule-no-curly-quotes";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
