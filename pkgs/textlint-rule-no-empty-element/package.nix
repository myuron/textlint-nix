{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-no-empty-element";
  # Upstream's tags stop at v0.1.3. This commit is the one published to npm as
  # 0.3.1, although its package.json still says 0.3.0.
  version = "0.3.1-unstable-2022-10-17";

  src = fetchFromGitHub {
    owner = "AhmedElwerdany";
    repo = "textlint-rule-no-empty-element";
    rev = "123f959e63a89813c92130a47a042256076c2a59";
    hash = "sha256-C/nOve51bXeGCxtUKY+QMSEZpXBEDGJkBIesTA7skUs=";
  };

  npmDepsHash = "sha256-xBE/qaCY6BD2lVGH2rFSokpO8/3kFaT/ys0uwuGC/ZY=";

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that checks if any element in a Markdown file is empty";
    homepage = "https://github.com/AhmedElwerdany/textlint-rule-no-empty-element";
    license = lib.licenses.isc;
    inherit (textlint.meta) platforms;
  };
})
