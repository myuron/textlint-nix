{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
  runCommand,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-no-invalid-control-character";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-no-invalid-control-character";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jTNootemRXec/jKFsToOdXdMPXAgGzl8VKpISEAXErU=";
  };

  npmDepsHash = "sha256-oHR5MHsfbn3Unoi2etKJNUMa1L078AivyQgNmAROguY=";

  # The prepare script runs `git config`, which is not available in the sandbox.
  npmPackFlags = [ "--ignore-scripts" ];

  # testPackages derives the rule name from pname, which cannot hold a scoped
  # name, so run textlint with the scoped rule name directly.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          grep @textlint-rule/no-invalid-control-character <(textlint --rule @textlint-rule/no-invalid-control-character ${./test.md}) > $out
        '';
  };

  meta = {
    description = "Textlint rule check unnessary control character in the document";
    homepage = "https://github.com/textlint-rule/textlint-rule-no-invalid-control-character";
    changelog = "https://github.com/textlint-rule/textlint-rule-no-invalid-control-character/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
