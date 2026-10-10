{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-no-mixed-zenkaku-and-hankaku-alphabet";
  version = "1.0.1";

  # The upstream release tag has no lockfile. Use the npm tarball, which
  # ships the built lib/, with a lockfile vendored here.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-no-mixed-zenkaku-and-hankaku-alphabet/-/textlint-rule-no-mixed-zenkaku-and-hankaku-alphabet-${finalAttrs.version}.tgz";
    hash = "sha256-w9R7uoH3mKj6tObgVgIBV2j2HNUySGUsKofqWCOK0QI=";
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

  npmDepsHash = "sha256-WuRJL3gpcs9wlzhMPDMfRKFl+5KH9w6bAxFJIyMa4Hk=";

  dontNpmBuild = true;

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that checks mixed full-width and half-width alphabets";
    homepage = "https://github.com/textlint-ja/textlint-rule-no-mixed-zenkaku-and-hankaku-alphabet";
    changelog = "https://github.com/textlint-ja/textlint-rule-no-mixed-zenkaku-and-hankaku-alphabet/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
