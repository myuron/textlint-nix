{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-ja-hiraku";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "akiomik";
    repo = "textlint-rule-ja-hiraku";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Jz8k616uVCfRIL0HwL3f62eduOIpv2h1upQGz4Rj81c=";
  };

  npmDepsHash = "sha256-+atlEg86tQ51+e4hSKf4NGUp+c/ri2fKhp86B3liZHc=";
  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that detects kanji that read better in hiragana";
    homepage = "https://github.com/akiomik/textlint-rule-ja-hiraku";
    changelog = "https://github.com/akiomik/textlint-rule-ja-hiraku/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    inherit (textlint.meta) platforms;
  };
})
