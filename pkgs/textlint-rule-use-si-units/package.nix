{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-use-si-units";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "kn1cht";
    repo = "textlint-rule-use-si-units";
    tag = "v${finalAttrs.version}";
    hash = "sha256-l+fLf0VVD/vwUKXQ11f9MGK5izAOBWe1OK94uG3gdwY=";
  };

  npmDepsHash = "sha256-/5i3oBuGG7okvKU7qfEAj/CYcGi3CS8PpgiEkqlnVos=";
  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule to always use the International System of Units (SI)";
    homepage = "https://github.com/kn1cht/textlint-rule-use-si-units";
    license = lib.licenses.isc;
    inherit (textlint.meta) platforms;
  };
})
