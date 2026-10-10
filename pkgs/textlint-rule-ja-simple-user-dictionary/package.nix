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
  runCommand,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "textlint-rule-ja-simple-user-dictionary";
  version = "1.0.1-unstable-2022-07-31";

  # Upstream has no tags. This is the commit that set the version to 1.0.1.
  src = fetchFromGitHub {
    owner = "hata6502";
    repo = "textlint-rule-ja-simple-user-dictionary";
    rev = "e5d1a8c1eebc985cf026a9b49794ecc7f4d77c13";
    hash = "sha256-XZwv0u8yI/730ILJU+umRQYxx7dznfUdlemzGHKvrAg=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-amSoPFNRxjny4oBNo5A6FQ4XVaveqdeT8xmnn8309jk=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  # The rule reports nothing without a dictionary, so textlint.testPackages
  # (which only passes --rule) cannot be used.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          grep ja-simple-user-dictionary <(textlint --config ${./textlintrc} ${./test.md}) > $out
        '';
  };

  meta = {
    description = "Textlint rule that checks Japanese text against a simple user dictionary";
    homepage = "https://github.com/hata6502/textlint-rule-ja-simple-user-dictionary";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
