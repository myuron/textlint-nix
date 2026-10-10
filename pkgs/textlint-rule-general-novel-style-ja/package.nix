{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-general-novel-style-ja";
  version = "1.3.0";

  # Upstream has no tags and no lockfile, and building it needs Babel 6. Use
  # the npm tarball, which ships the built lib/, with a lockfile vendored here.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-general-novel-style-ja/-/textlint-rule-general-novel-style-ja-${finalAttrs.version}.tgz";
    hash = "sha256-2fP1X4LAwJXtBL7qUGdGypijmOoKUB1kl1RDy6GhB4U=";
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

  npmDepsHash = "sha256-pH0F5fA4eRAGx+u0HHO9EAG0z9rlpG9YH2d5sARLgi4=";

  dontNpmBuild = true;

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule to follow the general style of Japanese novels";
    homepage = "https://github.com/io-monad/textlint-rule-general-novel-style-ja";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
