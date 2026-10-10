{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-period-in-header";
  version = "0.1.2";

  # Upstream's pnpm-lock.yaml (lockfileVersion 6.0) is rejected by the pnpm
  # versions in nixpkgs. Use the npm tarball, which ships the built lib/, with
  # a lockfile vendored here.
  #
  # package-lock.json was generated without devDependencies (only needed to
  # build lib/) and without the textlint peerDependency (npm would install a
  # second textlint next to the rule), so drop them from package.json to keep
  # both in sync.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-period-in-header/-/textlint-rule-period-in-header-${finalAttrs.version}.tgz";
    hash = "sha256-/OEvdO+XJMNLgvReFgAaCJujdg+F2WPxiSgDrA6otgE=";
  };

  # postPatch also runs in the npmDeps fetcher, where nativeBuildInputs are not
  # available, hence the absolute path to jq.
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies, .peerDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-bxNXjzsUuk8OHVBt0BPPi7L9sVl6kd5wM4uAmM8KRJ8=";

  dontNpmBuild = true;

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that checks for a period at the end of headers";
    homepage = "https://github.com/ohakutsu/textlint-rule-period-in-header";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
