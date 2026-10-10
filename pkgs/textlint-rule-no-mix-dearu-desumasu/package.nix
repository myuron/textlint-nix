{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-no-mix-dearu-desumasu";
  version = "6.0.4";

  # The upstream package-lock.json lacks `resolved` and `integrity` for many
  # packages, so npm cannot fetch the dependencies from it. Use the npm
  # tarball, which ships the built lib/, with a lockfile vendored here.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-no-mix-dearu-desumasu/-/textlint-rule-no-mix-dearu-desumasu-${finalAttrs.version}.tgz";
    hash = "sha256-WqiGWP5Ep/gy4/onwZ3T5oV0NRXImkbJpYwUDEpQC2I=";
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

  npmDepsHash = "sha256-wjOlmhMJdQP0YiBiCmPiHguYXxfyXfKR63aDs9i5r3Q=";

  dontNpmBuild = true;

  # The prepare script runs `git config`, which is not available in the sandbox.
  npmPackFlags = [ "--ignore-scripts" ];

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that disallows mixing である and ですます styles";
    homepage = "https://github.com/textlint-ja/textlint-rule-no-mix-dearu-desumasu";
    changelog = "https://github.com/textlint-ja/textlint-rule-no-mix-dearu-desumasu/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
