{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-gc-product-name";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "danishi";
    repo = "textlint-rule-gc-product-name";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dhsjSD79im7KB+nm+lXqZbN/ITnUc/FU/14YnFti6RM=";
  };

  npmDepsHash = "sha256-FqzDIzW2nYytPFxNlYMUt8qI+mDgRjN8j6YnQ/wB3L8=";

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that checks Google Cloud product names";
    homepage = "https://github.com/danishi/textlint-rule-gc-product-name";
    changelog = "https://github.com/danishi/textlint-rule-gc-product-name/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
