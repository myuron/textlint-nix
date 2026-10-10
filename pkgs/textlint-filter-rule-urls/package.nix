{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  runCommand,
  textlint,
  textlint-rule-no-todo,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-filter-rule-urls";
  version = "1.0.2";

  # Upstream uses yarn, but its yarn.lock cannot be used. url-regex-safe 1.0.2
  # requires the native addon re2 unconditionally, and the yarn hooks do not
  # run install scripts, so the addon is never built and textlint cannot load
  # the filter. The re2 1.15.9 pinned by yarn.lock also predates current
  # Node.js. Use the npm tarball, which ships the built dist/, with a lockfile
  # vendored here that resolves re2 to a version that builds (1.27.0), and let
  # npm rebuild compile it.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-filter-rule-urls/-/textlint-filter-rule-urls-${finalAttrs.version}.tgz";
    hash = "sha256-wOSFvhst7EI65OkcNp2PCvb/Q9QVjQSD6ZMMz8tsY5c=";
  };

  # package-lock.json was generated without devDependencies (they are only
  # needed to build dist/), so drop them from package.json to keep both in
  # sync. postPatch also runs in the npmDeps fetcher, where nativeBuildInputs
  # are not available, hence the absolute path to jq.
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-OXlQoPi3GhfeGDrtCmkS5TrMm5OO+0yWK9I+fUPMHx4=";

  dontNpmBuild = true;

  # Drop the intermediate files of the re2 build; only re2.node is needed.
  postInstall = ''
    rm -r $out/lib/node_modules/textlint-filter-rule-urls/node_modules/re2/build/Release/{obj.target,.deps}
  '';

  # A filter rule reports nothing on its own and can only be enabled from
  # .textlintrc, so textlint.testPackages cannot be used. test.txt violates
  # no-todo twice, once where the filter applies: check that only the other
  # one is reported with the filter, and both without it.
  #
  # test.txt rather than test.md: in Markdown a bare URL becomes a Link node,
  # and no-todo ignores everything under a Link, so nothing would be reported
  # there even without the filter.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        {
          nativeBuildInputs = [
            (textlint.withPackages [
              finalAttrs.finalPackage
              textlint-rule-no-todo
            ])
          ];
        }
        ''
          textlint --config ${./textlintrc} ${./test.txt} > result.txt || true
          cat result.txt
          test "$(grep -c no-todo result.txt)" -eq 1

          textlint --rule no-todo ${./test.txt} > result-unfiltered.txt || true
          cat result-unfiltered.txt
          test "$(grep -c no-todo result-unfiltered.txt)" -eq 2

          cp result.txt $out
        '';
  };

  meta = {
    description = "Textlint filter rule that ignores reported errors at URLs";
    homepage = "https://github.com/textlint-rule/textlint-filter-rule-urls";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
