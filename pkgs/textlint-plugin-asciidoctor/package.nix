{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
  textlint-rule-max-comma,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-plugin-asciidoctor";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "seikichi";
    repo = "textlint-plugin-asciidoctor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-u8ImZRKq0OiRSmJ/526LtY/Ly4I1tkF8IsomjnzftiY=";
  };

  npmDepsHash = "sha256-Q13l8M2G4t6ngFUVC5nOLHvSx+Fn/FK+0dIZ4XO8noA=";

  passthru.tests = textlint.testPackages {
    inherit (finalAttrs) pname;
    rule = textlint-rule-max-comma;
    plugin = finalAttrs.finalPackage;
    testFile = ./test.adoc;
  };

  meta = {
    description = "Asciidoctor support for textlint using asciidoctor.js";
    homepage = "https://github.com/seikichi/textlint-plugin-asciidoctor";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
