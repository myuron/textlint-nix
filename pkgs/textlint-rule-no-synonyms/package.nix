{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  nodejs,
  jq,
  textlint,
  runCommand,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "textlint-rule-no-synonyms";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-no-synonyms";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7oU0bpA07LOLR5qHuaIRCGW10jjbeB7Egs5Q7dOIMhk=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-izLeDbkmwUiBoMuB+Dj7xkvVxJdxcAn7J6G/HTf9aBM=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
    jq
  ];

  # sudachi-synonyms-dictionary is a peer dependency that the rule cannot load
  # without. Upstream locks it as a devDependency, so move it to dependencies
  # to keep it in the production install.
  postPatch = ''
    jq '.dependencies."sudachi-synonyms-dictionary" = .devDependencies."sudachi-synonyms-dictionary"
      | del(.devDependencies."sudachi-synonyms-dictionary")' package.json > package.json.tmp
    mv package.json.tmp package.json
  '';

  # testPackages derives the rule name from pname, which cannot hold a scoped
  # name, so run textlint with the scoped rule name directly.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          grep @textlint-ja/no-synonyms <(textlint --rule @textlint-ja/no-synonyms ${./test.md}) > $out
        '';
  };

  meta = {
    description = "同義語を表記ゆれをチェックするtextlintルール";
    homepage = "https://github.com/textlint-ja/textlint-rule-no-synonyms";
    changelog = "https://github.com/textlint-ja/textlint-rule-no-synonyms/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
