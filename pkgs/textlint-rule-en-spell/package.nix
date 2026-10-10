{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  nodejs,
  textlint,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "textlint-rule-en-spell";
  version = "1.2.4-unstable-2022-02-01";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "hata6502";
    repo = "textlint-rule-en-spell";
    rev = "9e0e6564f8b77c541034e5a8e92fc42054c77dd2";
    hash = "sha256-8HZgYNUO/0dAe8UmsqeOiUCVrw6UggOyzBXxIPmB51A=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-ARtyBVGC7tYNKNHYPOZQ9PbYPYqAxn3/U/7GHX1g3+8=";
  };

  # Upstream's build script is called "webpack".
  yarnBuildScript = "webpack";

  # webpack 4 hashes with MD4, which OpenSSL 3 only provides in legacy mode.
  env.NODE_OPTIONS = "--openssl-legacy-provider";

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule to check English spelling, with the dictionary included";
    homepage = "https://github.com/hata6502/textlint-rule-en-spell";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
