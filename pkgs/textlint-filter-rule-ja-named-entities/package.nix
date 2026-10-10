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
  textlint-rule-max-kanji-continuous-len,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "textlint-filter-rule-ja-named-entities";
  # Upstream has no tags. package.json at this commit says 1.0.3, and the commit
  # is from the same day as the 1.0.3 release on npm.
  version = "1.0.3-unstable-2021-04-24";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-filter-rule-ja-named-entities";
    rev = "d0fe006f9687137aef0e91d5e8e8e6b33747a63c";
    hash = "sha256-y4bG+P20bNAezNaVkRrum7gp88+kn10Tqgy366PEjfE=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-pi55SZ0JlCtleJQOktZ13Fe87MypvEZCFd3S1bmZmcU=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  # The upstream script that builds dist/ is named "tsc", not "build".
  yarnBuildScript = "tsc";

  # A filter rule reports nothing on its own and can only be enabled from
  # .textlintrc, so textlint.testPackages cannot be used. test.md violates
  # max-kanji-continuous-len twice, once on a named entity, where the filter
  # applies: check that only the other one is reported with the filter, and
  # both without it. no-todo, which the other filter rules are tested with,
  # cannot be violated on a named entity.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        {
          nativeBuildInputs = [
            (textlint.withPackages [
              finalAttrs.finalPackage
              textlint-rule-max-kanji-continuous-len
            ])
          ];
        }
        ''
          textlint --config ${./textlintrc} ${./test.md} > result.txt || true
          cat result.txt
          test "$(grep -c max-kanji-continuous-len result.txt)" -eq 1

          textlint --rule max-kanji-continuous-len ${./test.md} > result-unfiltered.txt || true
          cat result-unfiltered.txt
          test "$(grep -c max-kanji-continuous-len result-unfiltered.txt)" -eq 2

          cp result.txt $out
        '';
  };

  meta = {
    description = "日本語の固有表現を取り除くtextlintフィルタールール";
    homepage = "https://github.com/textlint-ja/textlint-filter-rule-ja-named-entities";
    # The bundled dictionary is derived from a Wikipedia-based dataset.
    license = lib.licenses.cc-by-sa-30;
    inherit (textlint.meta) platforms;
  };
})
