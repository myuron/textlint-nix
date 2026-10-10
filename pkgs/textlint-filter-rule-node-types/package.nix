{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  nodejs,
  runCommand,
  textlint,
  textlint-rule-no-todo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "textlint-filter-rule-node-types";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "textlint";
    repo = "textlint-filter-rule-node-types";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ysXFvRt2kKiy/FxXSEfFxYckbSr/T74ZT7L2jOnV75U=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-Ilo9wnBRjAsrQOjVgYimnYDtphL4EWBJoWIuEX2mqso=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  # A filter rule reports nothing on its own and can only be enabled from
  # .textlintrc, so textlint.testPackages cannot be used. test.md violates
  # no-todo twice, once where the filter applies: check that only the other
  # one is reported with the filter, and both without it.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        {
          nativeBuildInputs = [
            (textlint.withPackages [
              finalAttrs.finalPackage
              textlint-rule-no-todo
            ])
          ];
        }
        ''
          textlint --config ${./textlintrc} ${./test.md} > result.txt || true
          cat result.txt
          test "$(grep -c no-todo result.txt)" -eq 1

          textlint --rule no-todo ${./test.md} > result-unfiltered.txt || true
          cat result-unfiltered.txt
          test "$(grep -c no-todo result-unfiltered.txt)" -eq 2

          cp result.txt $out
        '';
  };

  meta = {
    description = "Textlint filter rule that ignores errors in nodes of the given types";
    homepage = "https://github.com/textlint/textlint-filter-rule-node-types";
    changelog = "https://github.com/textlint/textlint-filter-rule-node-types/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
