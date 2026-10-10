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
  pname = "textlint-rule-no-unmatched-pair";
  version = "2.0.4";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-no-unmatched-pair";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UDlKnjxFEQBnQ9hI9x6KsvbyJ7Fsr0c5+OrO/Aema7M=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-mTU+wCXBIC+UVFkKgKeOFqijALzgwHy3TsbQYxfMOG8=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  # testPackages derives the rule name from pname, which cannot hold a scoped
  # name, so run textlint with the scoped rule name directly.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          grep @textlint-rule/no-unmatched-pair <(textlint --rule @textlint-rule/no-unmatched-pair ${./test.md}) > $out
        '';
  };

  meta = {
    description = "Textlint rule that check unmatched pairs like \"（\" and \")\"";
    homepage = "https://github.com/textlint-rule/textlint-rule-no-unmatched-pair";
    changelog = "https://github.com/textlint-rule/textlint-rule-no-unmatched-pair/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
