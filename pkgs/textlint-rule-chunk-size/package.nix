{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
  runCommand,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-chunk-size";
  version = "1.0.4-unstable-2023-04-08";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "hoffination";
    repo = "textlint-rule-chunk-size";
    rev = "98e6d534bd6cc24b545ff98963fb1594769b8e26";
    hash = "sha256-pl6YzrwgMHCb0kDdStataag8x/Ki05AFHyh7KJWZcPA=";
  };

  npmDepsHash = "sha256-N1uWO+u8CHohkguLPvsuyxnpc1rRrtb8wcn8qKCNEkg=";

  # With the default chunkSize of 2000 the test document would have to be
  # longer than that, so pass a small chunkSize instead of using
  # textlint.testPackages (which only passes --rule).
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          grep "Found Error.*chunk-size" <(textlint --config ${./textlintrc} ${./test.md}) > $out
        '';
  };

  meta = {
    description = "Textlint rule that limits the number of characters between delimiters";
    homepage = "https://github.com/hoffination/textlint-rule-chunk-size";
    license = lib.licenses.isc;
    inherit (textlint.meta) platforms;
  };
})
