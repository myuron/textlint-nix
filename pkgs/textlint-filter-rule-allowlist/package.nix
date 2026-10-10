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
  pname = "textlint-filter-rule-allowlist";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "textlint";
    repo = "textlint-filter-rule-allowlist";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ookE9mRz7/gxon9Sx1IZ1YdmtgRk7OsJFKiLE147Kms=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-S1Ta8l0FtHx0mvHlWZtZ2fjJNwR9g5OQrH5vGlKzLUM=";
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
    description = "Textlint filter rule that filters any word by allowing lists";
    homepage = "https://github.com/textlint/textlint-filter-rule-allowlist";
    changelog = "https://github.com/textlint/textlint-filter-rule-allowlist/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
