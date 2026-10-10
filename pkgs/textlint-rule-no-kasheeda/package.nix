{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-no-kasheeda";
  version = "1.0.7-unstable-2024-07-11";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "aborazmeh";
    repo = "textlint-rule-no-kasheeda";
    rev = "8e8db3ee7caca85b37d69811f345374a44c0a9e9";
    hash = "sha256-HH9WjoQo3L8CSDBaEgT1z1bsgT9jFjVbKmX1L8UWUQw=";
  };

  npmDepsHash = "sha256-zwELl+JbPeNUzipwF0DvAyFPXoTWjR0t/q38eQv7ivc=";

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that disallows the kasheeda (U+0640) in languages like Arabic and Farsi";
    homepage = "https://github.com/aborazmeh/textlint-rule-no-kasheeda";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
