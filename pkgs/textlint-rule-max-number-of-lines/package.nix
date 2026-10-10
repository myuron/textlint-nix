{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
  runCommand,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-max-number-of-lines";
  version = "1.0.3";

  # Upstream has no lockfile, and building it needs Babel 6. Use the npm
  # tarball, which ships the built lib/, with a lockfile vendored here.
  #
  # package-lock.json was generated without devDependencies (they are only
  # needed to build lib/), so drop them from package.json to keep both in sync.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-max-number-of-lines/-/textlint-rule-max-number-of-lines-${finalAttrs.version}.tgz";
    hash = "sha256-me0sHWWBptI6tQAhU9htNtoG5BbMxJ9gGwjRp0iIWjU=";
  };

  # postPatch also runs in the npmDeps fetcher, where nativeBuildInputs are not
  # available, hence the absolute path to jq.
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-aLO8Ri7iHJ/uQS73qnMNW5LmEJw6tXU7Yn+U+1OLUlc=";

  dontNpmBuild = true;

  # The default limit is 300 lines. Lower it with a config instead of shipping a
  # test document that long.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          grep max-number-of-lines <(textlint --config ${./textlintrc} ${./test.md}) > $out
        '';
  };

  meta = {
    description = "Textlint rule for linting number of lines";
    homepage = "https://github.com/textlint-rule/textlint-rule-max-number-of-lines";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
