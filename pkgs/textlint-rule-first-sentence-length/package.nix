{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-first-sentence-length";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-first-sentence-length";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iU8ESMekvRXFCdA7MMlMCXQA8SXJSvlHAQwUOcjUpkE=";
  };

  npmDepsHash = "sha256-rUrAy52qS4v+CU2LTBsL0devsgOhwImmAI/iJl3vU80=";

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that limits the maximum length of the first sentence of a section";
    homepage = "https://github.com/textlint-rule/textlint-rule-first-sentence-length";
    changelog = "https://github.com/textlint-rule/textlint-rule-first-sentence-length/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
