{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-no-surrogate-pair";
  version = "1.0.1";

  # Upstream has no lockfile, and building it needs Babel 6. Use the npm
  # tarball, which ships the built lib/, with a lockfile vendored here.
  #
  # package-lock.json was generated without devDependencies (they are only
  # needed to build lib/), so drop them from package.json to keep both in sync.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-no-surrogate-pair/-/textlint-rule-no-surrogate-pair-${finalAttrs.version}.tgz";
    hash = "sha256-EmE/33gxdKdy/k3lfbHTmM/SiVmi2CM/tlI3iAspbcE=";
  };

  # postPatch also runs in the npmDeps fetcher, where nativeBuildInputs are not
  # available, hence the absolute path to jq.
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-fci4YnEEQ0C6ax2WHFNXe+pJNccz+F5dOfOTdW9Eqnc=";

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
    description = "Textlint rule that detects surrogate pairs in sentences";
    homepage = "https://github.com/lostandfound/textlint-rule-no-surrogate-pair";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
