{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-alive-link";
  version = "0.1.2";

  # Upstream has no tags, and its pnpm-lock.yaml (lockfileVersion 5.4) is
  # rejected by the pnpm versions in nixpkgs. Use the npm tarball, which ships
  # the built lib/, with a lockfile vendored here.
  #
  # package-lock.json was generated without devDependencies (only needed to
  # build lib/) and without the textlint peerDependency (npm would install a
  # second textlint next to the rule), so drop them from package.json to keep
  # both in sync.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-alive-link/-/textlint-rule-alive-link-${finalAttrs.version}.tgz";
    hash = "sha256-S1CyDr/waJ4uyFfXImdHmEHGXKPZJDxHLdJZzOMz0D4=";
  };

  # postPatch also runs in the npmDeps fetcher, where nativeBuildInputs are not
  # available, hence the absolute path to jq.
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies, .peerDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-kZu6Gnn+4EFX4HqAYz1+BlHnaOf55/Smxs+ELMN4xbM=";

  dontNpmBuild = true;

  # The sandbox has no network. A relative link to a missing file is checked
  # on the filesystem and reported without one.
  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule to check if all links are alive";
    homepage = "https://github.com/fengma1992/textlint-rule-alive-link";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
