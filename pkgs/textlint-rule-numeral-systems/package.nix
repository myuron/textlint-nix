{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-numeral-systems";
  version = "1.0.0-unstable-2024-07-13";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "aborazmeh";
    repo = "textlint-rule-numeral-systems";
    rev = "e23dba09cf0101cc278c174b9f359d154de31eee";
    hash = "sha256-4Wxr1nbMJ9y8+C89O/IKukQaTpOp3+XbgV22nchSads=";
  };

  npmDepsHash = "sha256-eoeLn7mwcFCPgpJftWudjXrCJ0szRApORKxZyZXpce0=";

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that unifies the usage of Arabic, Arabic-Indic and Persian numerals in a text";
    homepage = "https://github.com/aborazmeh/textlint-rule-numeral-systems";
    # package.json says MIT, but the LICENSE file is MIT No Attribution.
    license = lib.licenses.mit0;
    inherit (textlint.meta) platforms;
  };
})
