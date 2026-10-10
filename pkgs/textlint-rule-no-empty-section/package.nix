{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-no-empty-section";
  version = "1.1.0";

  # Upstream has no lockfile, and building it needs Babel 6. Use the npm
  # tarball, which ships the built lib/, with a lockfile vendored here.
  #
  # package-lock.json was generated without devDependencies (they are only
  # needed to build lib/), so drop them from package.json to keep both in sync.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-no-empty-section/-/textlint-rule-no-empty-section-${finalAttrs.version}.tgz";
    hash = "sha256-5rxOKJkMnxpFAHFy9BBKkCHUWaurQ+6MNPv0/MZjNNE=";
  };

  # postPatch also runs in the npmDeps fetcher, where nativeBuildInputs are not
  # available, hence the absolute path to jq.
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-1wRcwz0N9ujDKwqUaeyaxpfmXDczJlxmQnDKf0PQNNk=";

  dontNpmBuild = true;

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule not allow to create empty section";
    homepage = "https://github.com/azu/textlint-rule-no-empty-section";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
