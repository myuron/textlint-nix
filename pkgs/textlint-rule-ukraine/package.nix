{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-ukraine";
  version = "1.5.8";

  src = fetchFromGitHub {
    owner = "damian-buho";
    repo = "textlint-rule-ukraine";
    tag = finalAttrs.version;
    hash = "sha256-KeZIQhn/mDhVMuU2eBl9nTXODNOk7INTaF/lliDzeNc=";
  };

  npmDepsHash = "sha256-Tj/X/HlX8sgDknFeYBAZoCjVOoGeshC0ozsalriGphA=";

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that flags russified transliterations of Ukrainian place and person names";
    homepage = "https://github.com/damian-buho/textlint-rule-ukraine";
    changelog = "https://github.com/damian-buho/textlint-rule-ukraine/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
