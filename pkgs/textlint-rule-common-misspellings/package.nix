{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-common-misspellings";
  version = "1.0.1";

  # Upstream has no tags and no lockfile, and building it needs Babel 6. Use
  # the npm tarball, which ships the built lib/, with a lockfile vendored here.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-common-misspellings/-/textlint-rule-common-misspellings-${finalAttrs.version}.tgz";
    hash = "sha256-5QVb5T2yGuunNhRQG5brJQyicRRbO8XewzjO2RzN0bI=";
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

  npmDepsHash = "sha256-YnsM2X5LbSYrqx41dbv7IrZINvJVYsyG4yL/F13Lqu4=";

  dontNpmBuild = true;

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule to check common misspellings";
    homepage = "https://github.com/io-monad/textlint-rule-common-misspellings";
    license = lib.licenses.gpl3Only;
    inherit (textlint.meta) platforms;
  };
})
