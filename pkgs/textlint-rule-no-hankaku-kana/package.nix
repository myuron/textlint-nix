{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-no-hankaku-kana";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-no-hankaku-kana";
    tag = "v${finalAttrs.version}";
    hash = "sha256-73WdBO1zP2vYsyHvJvs/DMVmlpX85HbFRfQ/4SV+O5A=";
  };

  npmDepsHash = "sha256-S2EyGMwngGvACesvwF58umisuxBm4jiHNwXerGDdeLE=";

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that disallow to use 半角カタカナ";
    homepage = "https://github.com/textlint-ja/textlint-rule-no-hankaku-kana";
    changelog = "https://github.com/textlint-ja/textlint-rule-no-hankaku-kana/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
