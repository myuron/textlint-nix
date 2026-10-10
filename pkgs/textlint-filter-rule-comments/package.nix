{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  runCommand,
  textlint,
  textlint-rule-no-todo,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-filter-rule-comments";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "textlint";
    repo = "textlint-filter-rule-comments";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iTC2BeOctlzJcX8Cp1wFwNtrW5n2bglmVU5bwDjr6E4=";
  };

  npmDepsHash = "sha256-eTHVWRBgEi/9/cDSDZ4g00E/9ZZqgb0OliXtxdmCCNk=";

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
    description = "Textlint filter rule that ignores errors using comment directives";
    homepage = "https://github.com/textlint/textlint-filter-rule-comments";
    changelog = "https://github.com/textlint/textlint-filter-rule-comments/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
