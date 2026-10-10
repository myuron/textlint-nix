{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-ja-overlooked-typo";
  version = "0.0.1-unstable-2024-08-14";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "GunseiKPaseri";
    repo = "textlint-rule-ja-overlooked-typo";
    rev = "abdc5a6617079fa20703d35a54e4b316e98e21b1";
    hash = "sha256-s+K7pjNlIhm2zILTEmGyEqX7MBavXkdZIdaScNg1+OU=";
  };

  npmDepsHash = "sha256-0v5dmdSyVlMlIFWRuJn8X6nAA8ktiFsK9tjLWey2dGM=";
  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that detects easily overlooked typos in Japanese";
    homepage = "https://github.com/GunseiKPaseri/textlint-rule-ja-overlooked-typo";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
