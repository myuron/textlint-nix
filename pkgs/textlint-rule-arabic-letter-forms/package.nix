{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-arabic-letter-forms";
  version = "1.0.1-unstable-2024-07-11";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "aborazmeh";
    repo = "textlint-rule-arabic-letter-forms";
    rev = "8c807fdbb8e8db97fe066ec455a22f41d8029aa7";
    hash = "sha256-WnpbJQvcWv+ImGicOtlYZE6FPZrXQcqdv9+7JgaKviQ=";
  };

  npmDepsHash = "sha256-VnIQIqvow+4IuaasxjxNLO2k3NH3CtsPwOB8UFZzmyI=";

  # The build script first generates lib/data.json (src/update.js) and only
  # then compiles src/ into lib/. In a clean tree lib/ does not exist yet, the
  # write fails without failing the build, and the rule later crashes because
  # data.json is missing.
  preBuild = ''
    mkdir -p lib
  '';

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that finds Arabic presentation forms of letters (isolated, initial, medial, final) and normalizes them";
    homepage = "https://github.com/aborazmeh/textlint-rule-arabic-letter-forms";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
