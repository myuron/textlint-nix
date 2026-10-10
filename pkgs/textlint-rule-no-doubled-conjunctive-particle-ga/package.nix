{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-no-doubled-conjunctive-particle-ga";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-no-doubled-conjunctive-particle-ga";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ozNjNeuq/vo5jsoFCpQ37XiAlQa19VlwvTrtd/eMGUY=";
  };

  npmDepsHash = "sha256-rmOXGVsWbrG/JYTyyNe5Xcbqx7mFQ2lcta+fWC2SEs4=";

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that checks doubled conjunctive particle が in a sentence";
    homepage = "https://github.com/textlint-ja/textlint-rule-no-doubled-conjunctive-particle-ga";
    changelog = "https://github.com/textlint-ja/textlint-rule-no-doubled-conjunctive-particle-ga/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
