{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-max-appearence-count-of-words";
  version = "1.0.1";

  # Upstream has no lockfile, and building it needs Babel 5. Use the npm
  # tarball, which ships the built lib/, with a lockfile vendored here.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-max-appearence-count-of-words/-/textlint-rule-max-appearence-count-of-words-${finalAttrs.version}.tgz";
    hash = "sha256-MXZhgGB/BpZcedl+V6CYG9uYlcP2JNDRQzR5gtXwsyE=";
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

  npmDepsHash = "sha256-UKnvyMcThXgZ0z0Wp+wV7FfhB0gJahV/Yn37nQjFQWg=";

  dontNpmBuild = true;

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that limits how many times a word appears in a paragraph";
    homepage = "https://github.com/KeitaMoromizato/textlint-rule-max-appearence-count-of-words";
    changelog = "https://github.com/KeitaMoromizato/textlint-rule-max-appearence-count-of-words/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
