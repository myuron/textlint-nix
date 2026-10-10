{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-ja-hiragana-hojodoushi";
  version = "1.1.0";

  # Upstream ships both lockfiles; package-lock.json is the one updated at the
  # release, yarn.lock is stale.
  src = fetchFromGitHub {
    owner = "lostandfound";
    repo = "textlint-rule-ja-hiragana-hojodoushi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5OBwXfLPeFAOdxGZGcSy74cZgeS6ASTiEQXc/tWI9AA=";
  };

  npmDepsHash = "sha256-JLb1oAc91v4TwzFpBWrKTaLqAh7AYCEoTY2TH+HBBDo=";

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that prefers hiragana for auxiliary verbs (補助動詞)";
    homepage = "https://github.com/lostandfound/textlint-rule-ja-hiragana-hojodoushi";
    changelog = "https://github.com/lostandfound/textlint-rule-ja-hiragana-hojodoushi/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
