{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
  runCommand,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-header-levels";
  version = "1.0.2-unstable-2024-07-15";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "aborazmeh";
    repo = "textlint-rule-header-levels";
    rev = "6c155a7e3da4ccdb09a38873f931479ee912f8a9";
    hash = "sha256-RseGGLR4XBDrGoO3pBmfUKAQZevoagCEDbUxP4OR+J8=";
  };

  npmDepsHash = "sha256-nFI047sjD/ivwuAgrIDE7F2OXqIdK1Mr54w4NyZ8+QQ=";

  # The default range (1 to 6) allows every Markdown header, so the rule
  # reports nothing without options and textlint.testPackages (which only
  # passes --rule) cannot be used.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          grep header-levels <(textlint --config ${./textlintrc} ${./test.md}) > $out
        '';
  };

  meta = {
    description = "Textlint rule that specifies the least and most allowed header levels";
    homepage = "https://github.com/aborazmeh/textlint-rule-header-levels";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
