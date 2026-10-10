{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-zh-half-and-full-width-bracket";
  version = "1.1.0";

  # Upstream has no tags, and its yarn.lock resolves every package from a
  # private registry mirror (r.npm.sankuai.com) that fetchYarnDeps cannot
  # reach. Use the npm tarball, which ships the built lib/, with a lockfile
  # vendored here.
  #
  # package-lock.json was generated without devDependencies (only needed to
  # build lib/) and without the textlint peerDependency (npm would install a
  # second textlint next to the rule), so drop them from package.json to keep
  # both in sync.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-zh-half-and-full-width-bracket/-/textlint-rule-zh-half-and-full-width-bracket-${finalAttrs.version}.tgz";
    hash = "sha256-ltqxwfPfsKn8lhT4JjaaURAElVOamAQhBLOm6DRV8cU=";
  };

  # postPatch also runs in the npmDeps fetcher, where nativeBuildInputs are not
  # available, hence the absolute path to jq.
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies, .peerDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-OYXhNYoEYgCPYgJK6UqxZcNh0zVJZr8JCfjt44okgoE=";

  dontNpmBuild = true;

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that checks full-width and half-width brackets in Chinese text";
    homepage = "https://github.com/ylc395/textlint-rule-zh-half-and-full-width-bracket";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
