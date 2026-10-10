{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
  runCommand,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-spellchecker";
  version = "2.2.1";

  # Upstream has no tags, and its yarn.lock pins spellchecker 3.4.4 with
  # nan 2.5.1, a native module that predates current Node.js. Use the npm
  # tarball, which ships the built lib/, with a lockfile vendored here that
  # resolves to spellchecker 3.7.1 and a current nan.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-spellchecker/-/textlint-rule-spellchecker-${finalAttrs.version}.tgz";
    hash = "sha256-4jmI7H/idP9zmnE0pF9xExt8ih32ikG/PPkFZmE3TqA=";
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

  npmDepsHash = "sha256-oo9qnF9kNBSmntX0rniM7zmi6DjIyYSNnWIaDQtBJXI=";

  dontNpmBuild = true;

  # Without SPELLCHECKER_PREFER_HUNSPELL the module uses NSSpellChecker on
  # macOS, which depends on the system, so force the bundled Hunspell. Hunspell
  # looks for the dictionary of the language in $LANG and only en_US is
  # bundled, so set LANG to en_US.UTF-8.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          export SPELLCHECKER_PREFER_HUNSPELL=1
          export LANG=en_US.UTF-8
          grep spellchecker <(textlint --rule spellchecker ${./test.md}) > $out
        '';
  };

  meta = {
    description = "Textlint rule to check spelling with a native spellchecker (NSSpellChecker or Hunspell)";
    homepage = "https://github.com/textlint-rule/textlint-rule-spellchecker";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
