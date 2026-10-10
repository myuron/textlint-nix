{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-no-doubled-joshi";
  version = "5.1.1";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-no-doubled-joshi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ruSlq6BKlYArkcltVkKxNrEKLaevmKAdxJpyT0003o0=";
  };

  npmDepsHash = "sha256-qxnRWXSELCLR9D632D7xerf95uHy4FjeplZjfCMA2jE=";

  # The prepare script runs `git config`, which is not available in the sandbox.
  npmPackFlags = [ "--ignore-scripts" ];

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that checks doubled joshi (particles) in a sentence";
    homepage = "https://github.com/textlint-ja/textlint-rule-no-doubled-joshi";
    changelog = "https://github.com/textlint-ja/textlint-rule-no-doubled-joshi/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
