{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  runCommand,
  textlint,
  textlint-rule-max-comma,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-plugin-satsuki";
  version = "1.1.2";

  # Upstream has no tag for 1.1.2 and no lockfile, and building it needs
  # Babel 6. Use the npm tarball, which ships the built lib/, with a lockfile
  # vendored here.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-plugin-satsuki/-/textlint-plugin-satsuki-${finalAttrs.version}.tgz";
    hash = "sha256-CCXWy8b+NNlFUCk6Jyre5djH+nT3tLFK1i7Q6gJ1OkA=";
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

  npmDepsHash = "sha256-35jEznDwGHnYhKCa6Twssc18ipnHos6tCG+crw6JN9I=";

  dontNpmBuild = true;

  # Both this plugin and textlint's built-in text plugin handle .txt, and the
  # only thing this plugin adds is ignoring Satsuki blocks and inline tags.
  # textlint.testPackages would pass with either, so check instead that the
  # sentence inside the >> ... << block of test.txt is not reported: only the
  # one outside the block is.
  #
  # --plugin on the command line is the only way to get there. textlint puts
  # its built-in plugins ahead of the ones listed in .textlintrc, so a
  # "plugins": ["satsuki"] entry loses to the built-in text plugin. The second
  # run pins that down, so that the note in the README gets revisited when
  # textlint changes the order.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        {
          nativeBuildInputs = [
            (textlint.withPackages [
              finalAttrs.finalPackage
              textlint-rule-max-comma
            ])
          ];
        }
        ''
          textlint --plugin satsuki --rule max-comma ${./test.txt} > result.txt || true
          cat result.txt
          test "$(grep -c max-comma result.txt)" -eq 1

          textlint --config ${./textlintrc} ${./test.txt} > result-textlintrc.txt || true
          cat result-textlintrc.txt
          test "$(grep -c max-comma result-textlintrc.txt)" -eq 2

          cp result.txt $out
        '';
  };

  meta = {
    description = "Satsuki notation support for textlint";
    homepage = "https://github.com/7pairs/textlint-plugin-satsuki";
    license = lib.licenses.asl20;
    inherit (textlint.meta) platforms;
  };
})
