{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-azure-product-name";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "dora56";
    repo = "textlint-rule-azure-product-name";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8UXOMt0lgZY5YYbepxyFra4XGR3hmoXkO5t84jXpR0E=";
  };

  npmDepsHash = "sha256-GT00Dcm2Z3EeloUKv3DqGkV3nTtRXRgqaCZ6XMwFZdE=";

  # The rule reads its prh dictionaries from ../dict relative to lib/, but
  # "files" in package.json does not list dict/, so npmInstallHook leaves it
  # out and the rule fails with ENOENT.
  postInstall = ''
    cp -r dict $out/lib/node_modules/${finalAttrs.pname}/dict
  '';

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that checks Azure product names";
    homepage = "https://github.com/dora56/textlint-rule-azure-product-name";
    changelog = "https://github.com/dora56/textlint-rule-azure-product-name/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
