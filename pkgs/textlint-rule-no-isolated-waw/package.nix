{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-no-isolated-waw";
  version = "1.0.1-unstable-2024-07-09";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "aborazmeh";
    repo = "textlint-rule-no-isolated-waw";
    rev = "dfd94c3cbe61ed8ba2a991da44803ba895f0d180";
    hash = "sha256-L5kM7Yt85PvAEpDpd1Ojb8PWxndZ0YyI9LihVpHMaJg=";
  };

  npmDepsHash = "sha256-tEjOmewna3XOLPEL+BwJlBsNSuW1UAPTDTJsozBAy0w=";

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that ensures the Arabic conjunction waw is connected to the following word";
    homepage = "https://github.com/aborazmeh/textlint-rule-no-isolated-waw";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
