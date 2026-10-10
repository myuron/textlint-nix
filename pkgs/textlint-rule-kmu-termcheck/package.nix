{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
  runCommand,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-kmu-termcheck";
  # Upstream has no tags. This commit is the one published to npm as 1.1.1.
  version = "1.1.1-unstable-2023-03-22";

  src = fetchFromGitHub {
    owner = "kmuto";
    repo = "textlint-rule-kmu-termcheck";
    rev = "81f8838404d07ab3d7301c4b16c9ee07358847e2";
    hash = "sha256-Oj+vg5p+Vf++8RlrPbh9Kiy8nQGF64JziKSz0fdveYM=";
  };

  npmDepsHash = "sha256-wn+JeaeqU+7Warm0M6sx5YPzrTrIHFstFPDjtOwK0/M=";

  # testPackages derives the rule name from pname, which cannot hold a scoped
  # name, so run textlint with the scoped rule name directly.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          grep @kmuto/kmu-termcheck <(textlint --rule @kmuto/kmu-termcheck ${./test.md}) > $out
        '';
  };

  meta = {
    description = "Service name checker for textlint";
    homepage = "https://github.com/kmuto/textlint-rule-kmu-termcheck";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
