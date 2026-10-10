{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-apostrophe";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "sapegin";
    repo = "textlint-rule-apostrophe";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+2i6nJrKDJtG4yNu4voJ5YPz6Q3h5Hq6BUehmrXo1GA=";
  };

  npmDepsHash = "sha256-fJN6k0438aXYppAMF5GGhbfUhhinQ9/dFKkjDpeGcd0=";

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule to check correct apostrophe usage";
    homepage = "https://github.com/sapegin/textlint-rule-apostrophe";
    changelog = "https://github.com/sapegin/textlint-rule-apostrophe/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
