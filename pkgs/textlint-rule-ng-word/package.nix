{
  lib,
  buildNpmPackage,
  fetchurl,
  textlint,
  runCommand,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-ng-word";
  version = "1.0.0";

  # Upstream has no lockfile, and its package.json does not even list the
  # Babel it is built with. Use the npm tarball, which ships the built lib/,
  # with a lockfile vendored here.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-ng-word/-/textlint-rule-ng-word-${finalAttrs.version}.tgz";
    hash = "sha256-4QC8SDG3ehk43tAVM9XtdCU5CctXyZFDhOkxC9iM4m8=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-iYs9Rv5nvfTn5iMaQoOKXA4zyoyH75HyL5tFKrlDM4Q=";

  # The rule has no dependencies, so the npm cache is empty.
  forceEmptyCache = true;

  dontNpmBuild = true;

  # npmInstallHook fails without node_modules, which npm does not create for a
  # package without dependencies. The tarball already contains only the files
  # to install.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules
    cp -r . $out/lib/node_modules/${finalAttrs.pname}

    runHook postInstall
  '';

  # The rule reports nothing without a list of words, so textlint.testPackages
  # (which only passes --rule) cannot be used.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          grep ng-word <(textlint --config ${./textlintrc} ${./test.md}) > $out
        '';
  };

  meta = {
    description = "Textlint rule that checks NG words";
    homepage = "https://github.com/KeitaMoromizato/textlint-rule-ng-word";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
