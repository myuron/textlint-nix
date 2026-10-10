{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-no-doubled-conjunction";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-no-doubled-conjunction";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ypVe/iVWsY+ZbdG2iJymZqp3RTxeDz3Gsgm8tns6hxE=";
  };

  npmDepsHash = "sha256-1ek0Wyd57fb1zu/PkIyzCyD7d0hGd35XGZLNvmn5J70=";

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that checks the same conjunction used in consecutive sentences";
    homepage = "https://github.com/textlint-ja/textlint-rule-no-doubled-conjunction";
    changelog = "https://github.com/textlint-ja/textlint-rule-no-doubled-conjunction/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
