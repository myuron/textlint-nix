{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
  runCommand,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-neighbor";
  version = "2.2.0";

  # Upstream is an npm workspaces monorepo whose lockfile covers unrelated
  # apps. The rule itself needs no build, so use the npm tarball with a
  # lockfile vendored here.
  src = fetchurl {
    url = "https://registry.npmjs.org/@a11yfred/textlint-rule-neighbor/-/textlint-rule-neighbor-${finalAttrs.version}.tgz";
    hash = "sha256-x1UiTh0wGAGfGzXICPMmhbfM65D4TUwztxM7nQ1n4V4=";
  };

  # package-lock.json was generated without peerDependencies (textlint itself),
  # so drop them from package.json to keep both in sync. postPatch also runs in
  # the npmDeps fetcher, where nativeBuildInputs are not available, hence the
  # absolute path to jq.
  postPatch = ''
    ${lib.getExe jq} 'del(.peerDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-Is1HHIGgWp5n0jvksKekK8ioMFqSoccD3A+H5kW+DCY=";

  dontNpmBuild = true;

  # testPackages derives the rule name from pname, which cannot hold a scoped
  # name, so run textlint with the scoped rule name directly.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          grep @a11yfred/neighbor <(textlint --rule @a11yfred/neighbor ${./test.md}) > $out
        '';
  };

  meta = {
    description = "Textlint prose linting rules for accessibility";
    homepage = "https://github.com/a11yfred/neighbor/tree/main/packages/textlint-rule-neighbor";
    changelog = "https://github.com/a11yfred/neighbor/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
