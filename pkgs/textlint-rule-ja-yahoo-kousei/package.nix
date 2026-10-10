{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
  runCommand,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-ja-yahoo-kousei";
  version = "1.0.3";

  # Upstream has no lockfile, and building it needs Babel 6. Use the npm
  # tarball, which ships the built lib/, with a lockfile vendored here.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-ja-yahoo-kousei/-/textlint-rule-ja-yahoo-kousei-${finalAttrs.version}.tgz";
    hash = "sha256-B1NX7eqyhKcLCV51Ci8FSvjIecTMfOAWdR3IQGZbqu0=";
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

  npmDepsHash = "sha256-XD3+m981tmHPLg3h0zL16uWFRhJiyvreTl2Efri/f0o=";

  dontNpmBuild = true;

  # The rule sends every paragraph to the Yahoo! JAPAN proofreading API V1,
  # which needs an application ID and network access, and whose endpoint no
  # longer exists (it returns 404). Check instead that textlint loads the rule
  # and runs it far enough to hit its own check for the application ID.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          unset YAHOO_APP_ID
          grep -F "Error while loading rule 'ja-yahoo-kousei': YAHOO_APP_ID is not set." \
            <(textlint --rule ja-yahoo-kousei ${./test.md} 2>&1) > $out
        '';
  };

  meta = {
    description = "Textlint rule that proofreads Japanese with the Yahoo! JAPAN proofreading API";
    homepage = "https://github.com/KeitaMoromizato/textlint-rule-ja-yahoo-kousei";
    changelog = "https://github.com/KeitaMoromizato/textlint-rule-ja-yahoo-kousei/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
