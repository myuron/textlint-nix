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
  pname = "textlint-rule-no-duplicate-abbr";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-no-duplicate-abbr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1SWDgi542tc3zC8c5BIWhawCdDebgZdDwwBroDHXba0=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-lLPur6h7tiDjEqHYhlxMQ2l8z+kOjCrysVWgnzJAS5Y=";
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
          grep @textlint-rule/no-duplicate-abbr <(textlint --rule @textlint-rule/no-duplicate-abbr ${./test.md}) > $out
        '';
  };

  meta = {
    description = "Textlint rule that avoid adding duplicated suffix word for Acronyms and Abbreviations";
    homepage = "https://github.com/textlint-rule/textlint-rule-no-duplicate-abbr";
    changelog = "https://github.com/textlint-rule/textlint-rule-no-duplicate-abbr/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
