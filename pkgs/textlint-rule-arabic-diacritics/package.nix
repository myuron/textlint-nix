{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-arabic-diacritics";
  version = "1.0.0-unstable-2024-07-12";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "aborazmeh";
    repo = "textlint-rule-arabic-diacritics";
    rev = "f81e916622ad22c5204ab054327e6eaa9bbe6c66";
    hash = "sha256-gct/mfC5XJUm6EAHclqSKKRcWp0BCD+l4+l1zCyrTRs=";
  };

  npmDepsHash = "sha256-pLxn5PbcGJgmCprPOrdf3vB5kjYxPGDvK2CvYGPhgUI=";

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that checks the usage of Arabic diacritics";
    homepage = "https://github.com/aborazmeh/textlint-rule-arabic-diacritics";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
