{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-no-bold-paragraph";
  version = "1.0.0-unstable-2024-07-09";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "aborazmeh";
    repo = "textlint-rule-no-bold-paragraph";
    rev = "7deea27837e8e508da267e87cb870075a5dd6521";
    hash = "sha256-z86Y8zVjPMZSgCMB6G37Tg6GhO3NBelHHa8g7QrSY4k=";
  };

  npmDepsHash = "sha256-u6ud5ykhAWW88MEeCdVmaZkZzKwBdNtfTolAFUsudlk=";

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that looks for fully bolded paragraphs";
    homepage = "https://github.com/aborazmeh/textlint-rule-no-bold-paragraph";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
