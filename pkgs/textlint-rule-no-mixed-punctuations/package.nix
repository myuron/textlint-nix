{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-no-mixed-punctuations";
  version = "1.0.1-unstable-2024-07-08";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "aborazmeh";
    repo = "textlint-rule-no-mixed-punctuations";
    rev = "9dc4f730b6909a88f8bf5374ca9b1b985ca49d3a";
    hash = "sha256-kQsrEbdQHqZSR/mS9p3G7n9BdQjLyClD27+G7+qyvOc=";
  };

  npmDepsHash = "sha256-9s+yJQbb3s5bdS/jyvqAXnR9C0EQvxf64V/tAzT8Z2Q=";

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that prevents mixing LTR and RTL punctuation";
    homepage = "https://github.com/aborazmeh/textlint-rule-no-mixed-punctuations";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
