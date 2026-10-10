{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
  textlint-rule-max-comma,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-plugin-asciidoc-loose";
  version = "1.0.1";

  # Upstream has no lockfile, and building it needs Babel 6. Use the npm
  # tarball, which ships the built lib/, with a lockfile vendored here.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-plugin-asciidoc-loose/-/textlint-plugin-asciidoc-loose-${finalAttrs.version}.tgz";
    hash = "sha256-6YLsh2mBK145aGbgsTdu33+MKyebgaxliiF/Qkfl2s8=";
  };

  # package-lock.json was generated without devDependencies (they are only
  # needed to build lib/), so drop them from package.json to keep both in
  # sync. postPatch also runs in the npmDeps fetcher, where nativeBuildInputs
  # are not available, hence the absolute path to jq.
  #
  # vscode-textmate 1.x asks for oniguruma ^6, but 6.x uses V8 APIs that have
  # been removed from current Node.js and does not compile, so override it
  # with 7.2.3, the last release. This is outside the range upstream declares.
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies) | .overrides.oniguruma = "7.2.3"' package.json > package.json.tmp
    mv package.json.tmp package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-xd8fVFbMzhDbA5xbCt0KVnCi0xa8rCoGButzQk2DvPw=";

  dontNpmBuild = true;

  # The Oniguruma C sources bundled with the oniguruma module rely on
  # pre-C23 function declarations.
  env.CFLAGS = "-std=gnu17";

  passthru.tests = textlint.testPackages {
    inherit (finalAttrs) pname;
    rule = textlint-rule-max-comma;
    plugin = finalAttrs.finalPackage;
    testFile = ./test.adoc;
  };

  meta = {
    description = "AsciiDoc/Asciidoctor loose support for textlint";
    homepage = "https://github.com/azu/textlint-plugin-asciidoc-loose";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
