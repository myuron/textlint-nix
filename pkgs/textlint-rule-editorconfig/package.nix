{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
  runCommand,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-editorconfig";
  version = "1.0.3";

  # Upstream has no lockfile and no tag for 1.0.3, the latest release on npm
  # (the only tag is v1.0.0). Use the npm tarball with a lockfile vendored here.
  #
  # package-lock.json was generated without devDependencies (they are only
  # needed for the upstream tests), so drop them from package.json to keep both
  # in sync.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-editorconfig/-/textlint-rule-editorconfig-${finalAttrs.version}.tgz";
    hash = "sha256-dASwO+J9CMhLcbR36/Bzm8Oh2gfWkhnAsY/rkW2AB5c=";
  };

  # postPatch also runs in the npmDeps fetcher, where nativeBuildInputs are not
  # available, hence the absolute path to jq.
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-sIaFo6yv+O1srqWux6FIwT08vjI4E0FN/cl1fenCuz8=";

  dontNpmBuild = true;

  # The rule reads .editorconfig from the directories above the linted file, so
  # textlint.testPackages (which lints the file in the store) cannot be used.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          cp ${./editorconfig} .editorconfig
          cp ${./test.md} test.md

          grep editorconfig <(textlint --rule editorconfig test.md) > $out
        '';
  };

  meta = {
    description = "Textlint rule that lets EditorConfig and textlint work together";
    homepage = "https://github.com/arrowrowe/textlint-rule-editorconfig";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
