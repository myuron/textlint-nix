{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-terminology-zh";
  version = "0.0.1";

  # The upstream repository (fengma1992/textlint-rule-terminology-zh) no
  # longer exists. Use the npm tarball, which needs no build, with a lockfile
  # vendored here.
  #
  # package-lock.json was generated without devDependencies (only needed for
  # upstream's tests), so drop them from package.json to keep both in sync.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-terminology-zh/-/textlint-rule-terminology-zh-${finalAttrs.version}.tgz";
    hash = "sha256-wQhiAxpVw7+zyLetefQNi+Fy7rl+Q0qDYdlSLE3HmEM=";
  };

  # postPatch also runs in the npmDeps fetcher, where nativeBuildInputs are not
  # available, hence the absolute path to jq.
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-q2I0O4SwqqPZk4QeFOEH4gmmvFmqD3Z0Wj9dLuZY7Kk=";

  dontNpmBuild = true;

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule to check correct terms spelling in Chinese and English";
    homepage = "https://www.npmjs.com/package/textlint-rule-terminology-zh";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
