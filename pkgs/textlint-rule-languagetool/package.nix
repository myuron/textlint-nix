{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  jdk,
  languagetool,
  runCommand,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-languagetool";
  version = "1.0.0";

  # Upstream has no tags and no lockfile, and building it needs Babel 6. Use
  # the npm tarball, which ships the built lib/, with a lockfile vendored here.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-languagetool/-/textlint-rule-languagetool-${finalAttrs.version}.tgz";
    hash = "sha256-7MbvazPq3e6n+i+u6SlTec8zjCMpDEJKOl3Te7FtiRs=";
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

  npmDepsHash = "sha256-YnTTSUYz9HYz1GNNxTLn8gTdwVhIump9iLGkxtsqsWg=";

  dontNpmBuild = true;

  # The install scripts of node-jre and node-languagetool try to download an
  # Oracle JRE and LanguageTool.
  npmRebuildFlags = [ "--ignore-scripts" ];

  # Only for javac. The rule runs on languagetool.jre.
  nativeBuildInputs = [ jdk ];

  # The rule calls LanguageTool through node-languagetool, which expects the
  # JRE and the LanguageTool it downloads at install time. Point it at
  # LanguageTool from nixpkgs instead:
  #
  # - Service.java, the stdin/stdout bridge that node-languagetool runs, is
  #   written for LanguageTool 3.x. A method it calls was renamed since then.
  #   Compile it against the jars from nixpkgs into lt/, where index.js looks
  #   for Service.class.
  # - node-jre runs the JRE it bundles and exits on require on anything but
  #   x64. Start the JRE that LanguageTool from nixpkgs runs on directly.
  # - node-grd is only used to download LanguageTool.
  # - Put LanguageTool from nixpkgs on the classpath.
  #
  # The bugs of node-languagetool itself are left as upstream. See the README
  # for the limitations.
  postInstall = ''
    nlt=$out/lib/node_modules/textlint-rule-languagetool/node_modules/node-languagetool
    mkdir $nlt/lt
    substituteInPlace $nlt/resources/Service.java \
      --replace-fail getLanguageForShortName getLanguageForShortCode
    javac -cp "${languagetool}/share/libs/*" -d $nlt/lt $nlt/resources/Service.java
    substituteInPlace $nlt/index.js \
      --replace-fail "const jre = require('node-jre');" "const jre = { spawn: (classpath, classname, args, options) => require('child_process').spawn('${lib.getExe' languagetool.jre "java"}', ['-cp', classpath.join(':'), classname].concat(args), options) };" \
      --replace-fail "const grd = require('node-grd')" "" \
      --replace-fail "[ ltdir, path.join(ltdir, 'languagetool.jar'), 'resources' ]" "[ ltdir, '${languagetool}/share', '${languagetool}/share/libs/*' ]"
  '';

  # Not textlint.testPackages: bugs of node-languagetool can make textlint
  # hang, so run it under a timeout. test.md is limited to what completes with
  # node-languagetool as upstream: a single paragraph without inline markup.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          status=0
          timeout 300 textlint --rule languagetool ${./test.md} > output || status=$?
          cat output
          if [ "$status" -ne 1 ]; then
            echo "textlint exited with $status, expected 1"
            exit 1
          fi
          grep languagetool output > $out
        '';
  };

  meta = {
    description = "Textlint rule that checks text with LanguageTool";
    homepage = "https://github.com/UFOMelkor/textlint-rule-languagetool";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
