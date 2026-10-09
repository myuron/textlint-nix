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
  pname = "textlint-rule-prh";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-prh";
    tag = "v${finalAttrs.version}";
    hash = "sha256-K2WkHh7sLnhObM2ThvdXVbZymLInjSB6XTshxALotKU=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-tZMMadWue85L+5c7swKgFqUsLSARjS4EK0Cwi1FjX88=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  # prh reports nothing without a dictionary, so textlint.testPackages (which
  # only passes --rule) cannot be used. Point rulePaths at a dictionary bundled
  # with the prh dependency instead.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          substitute ${./textlintrc} .textlintrc \
            --subst-var-by textlint_rule_prh "${finalAttrs.finalPackage}"

          grep prh <(textlint ${./test.md}) > $out
        '';
  };

  meta = {
    description = "Textlint rule for prh";
    homepage = "https://github.com/textlint-rule/textlint-rule-prh";
    changelog = "https://github.com/textlint-rule/textlint-rule-prh/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
