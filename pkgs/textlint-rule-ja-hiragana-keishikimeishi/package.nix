{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-ja-hiragana-keishikimeishi";
  version = "1.1.0";

  # Upstream has no lockfile. Use the npm tarball, which ships the built lib/,
  # with a lockfile vendored here.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-ja-hiragana-keishikimeishi/-/textlint-rule-ja-hiragana-keishikimeishi-${finalAttrs.version}.tgz";
    hash = "sha256-xD2fe7+pePwujxRI4NFNIULmaItfZknDeu062LpTlRU=";
  };

  # package-lock.json was generated without devDependencies (they are only
  # needed to build lib/), so drop them from package.json to keep both in
  # sync. postPatch also runs in the npmDeps fetcher, where nativeBuildInputs
  # are not available, hence the absolute path to jq.
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-HWJoLLgDqYXjasEFoB/gClYr6Tqztv6VXSNjoe8kwvM=";

  dontNpmBuild = true;

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that prefers hiragana for formal nouns (形式名詞)";
    homepage = "https://github.com/lostandfound/textlint-rule-ja-hiragana-keishikimeishi";
    changelog = "https://github.com/lostandfound/textlint-rule-ja-hiragana-keishikimeishi/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
