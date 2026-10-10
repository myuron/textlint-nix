{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-ja-allowed-kanji";
  version = "1.0.1-unstable-2023-06-22";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "matori";
    repo = "textlint-rule-ja-allowed-kanji";
    rev = "ac9d10197f433b3eeda9ef9db43fb6e62e2a8a22";
    hash = "sha256-5NehsekFzZDyBTHgP9zZbsCWnnCGPhZprt1ZHT1n6nI=";
  };

  npmDepsHash = "sha256-Vevn/2LnPW6slKdzZntlbvshGcPD0xneORp0S6wOM4s=";
  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that allows only specified kanji characters";
    homepage = "https://github.com/matori/textlint-rule-ja-allowed-kanji";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
