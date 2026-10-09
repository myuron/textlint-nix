{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-diacritics";
  version = "1.0.0-unstable-2023-01-05";

  src = fetchFromGitHub {
    owner = "sapegin";
    repo = "textlint-rule-diacritics";
    rev = "07977d866aa6ce514bc6ed3a1087b2bb5869bfb4";
    hash = "sha256-Zr+qWvgpLq3pzO4A7c+x4rTKkaSNO4t1gCiyJL3lkws=";
  };

  npmDepsHash = "sha256-bKA8aPVBYdzRPwCyFdEs3eWStJwswCZPVpsqGWwc42E=";

  # Upstream has no build script.
  dontNpmBuild = true;

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule to check correct usage of diacritics";
    homepage = "https://github.com/sapegin/textlint-rule-diacritics";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
