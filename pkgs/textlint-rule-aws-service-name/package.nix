{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-aws-service-name";
  # Upstream's CI rewrites the version when it publishes to npm, so package.json
  # at the v1.14.0 tag still says 1.13.2.
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "bun913";
    repo = "textlint-rule-aws-service-name";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UMZgBxH0M103NP1DDde4NgNglxTOLnkNEjjvMVklh+4=";
  };

  npmDepsHash = "sha256-5WYklo54CRQI7SV+eAlp1Z5H/xvv8QJGb2Ag1LNmcEE=";

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that checks the names of AWS services";
    homepage = "https://github.com/bun913/textlint-rule-aws-service-name";
    changelog = "https://github.com/bun913/textlint-rule-aws-service-name/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
