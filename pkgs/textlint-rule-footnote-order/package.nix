{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
  runCommand,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-footnote-order";
  version = "1.0.3";

  # The yarn.lock upstream commits is empty (it only has the header), so there
  # is nothing for fetchYarnDeps to fetch, and building lib/ needs the
  # devDependencies it does not pin. Use the npm tarball, which ships the built
  # lib/, with a lockfile vendored here.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-footnote-order/-/textlint-rule-footnote-order-${finalAttrs.version}.tgz";
    hash = "sha256-BBe7MtZsRT8OCJWS6+89E59uuQhSV6xbPJxYWKqUhuY=";
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

  npmDepsHash = "sha256-CXz7I050QistRD7aIbRSgpTiOoGNXxld/dlnFfmiyIQ=";

  # The rule has no dependencies, so the npm cache is empty.
  forceEmptyCache = true;

  dontNpmBuild = true;

  # npmInstallHook fails without node_modules, which npm does not create for a
  # package without dependencies. The tarball already contains only the files
  # to install.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules
    cp -r . $out/lib/node_modules/${finalAttrs.pname}

    runHook postInstall
  '';

  # Not textlint.testPackages: the rule was written in 2019 against a Markdown
  # parser that had no footnote nodes, and looks for LinkReference and
  # Definition nodes whose identifier starts with "^". Since textlint 12
  # footnotes are parsed as FootnoteReference nodes, so the rule reports
  # nothing with current textlint, not even on test.md, whose footnotes are out
  # of order. Only check that textlint resolves and loads the rule and that the
  # lint completes without an error. If the rule cannot be resolved, textlint
  # exits with 2 and the test fails.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          status=0
          textlint --rule footnote-order ${./test.md} > output 2>&1 || status=$?
          cat output
          if [ "$status" -ne 0 ]; then
            echo "textlint exited with $status, expected 0"
            exit 1
          fi
          cp output $out
        '';
  };

  meta = {
    description = "Textlint rule to check that footnote identifiers are numbered incrementally";
    homepage = "https://github.com/textlint-rule/textlint-rule-footnote-order";
    changelog = "https://github.com/textlint-rule/textlint-rule-footnote-order/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
