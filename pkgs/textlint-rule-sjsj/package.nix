{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-sjsj";
  version = "1.0.5";

  # Upstream has no lockfile, and building it needs Babel 6. Use the npm
  # tarball, which ships the built lib/, with a lockfile vendored here.
  #
  # package-lock.json was generated without devDependencies (they are only
  # needed to build lib/), so drop them from package.json to keep both in sync.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-sjsj/-/textlint-rule-sjsj-${finalAttrs.version}.tgz";
    hash = "sha256-a3aZknBmCtIoxe12WbBQbBtqcLuEqdPvMHFGe+gcqXU=";
  };

  # postPatch also runs in the npmDeps fetcher, where nativeBuildInputs are not
  # available, hence the absolute path to jq.
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-5iq1zDG2H+5ffZaH919uQ7GiLe1zM+ez7Rvutk2nX8Q=";

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

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule to check the spelling of Simplified JavaScript Jargon";
    homepage = "https://github.com/azu/textlint-rule-sjsj";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
