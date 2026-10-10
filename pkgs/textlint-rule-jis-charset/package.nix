{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-jis-charset";
  version = "0.1.2";

  # Upstream has no lockfile. Use the npm tarball, which ships the built lib/,
  # with a lockfile vendored here.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-jis-charset/-/textlint-rule-jis-charset-${finalAttrs.version}.tgz";
    hash = "sha256-CUJzbiahBN27L5Ig1N9hQO69m2xVCvtsntf1AT775+Y=";
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

  npmDepsHash = "sha256-9nB7E/pBOUPpN5fIu2yL1KT7QcTyhOshjDJDo3TlhDQ=";

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
    description = "Textlint rule that reports characters outside JIS X 0213:2004";
    homepage = "https://github.com/lostandfound/textlint-rule-jis-charset";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
