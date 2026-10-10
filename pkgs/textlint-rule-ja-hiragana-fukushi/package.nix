{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  jq,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-ja-hiragana-fukushi";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "lostandfound";
    repo = "textlint-rule-ja-hiragana-fukushi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3K1VjN+jKMsSt0gDDnbXtAm94lOAAzzqxhdqSfAtUx4=";
  };

  # The upstream package-lock.json does not contain eslint, although
  # package.json lists it in devDependencies, so `npm ci` rejects the lockfile.
  # eslint is not needed for the build. postPatch also runs in the npmDeps
  # fetcher, where nativeBuildInputs are not available, hence the absolute
  # path to jq.
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies.eslint)' package.json > package.json.tmp
    mv package.json.tmp package.json
  '';

  npmDepsHash = "sha256-x0OpuORKUfCipbtT7Z4Qh3Vj10cjfMQLGDFPcQ3xUSQ=";

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that prefers hiragana for adverbs (副詞)";
    homepage = "https://github.com/lostandfound/textlint-rule-ja-hiragana-fukushi";
    changelog = "https://github.com/lostandfound/textlint-rule-ja-hiragana-fukushi/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
