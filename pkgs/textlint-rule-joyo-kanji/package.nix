{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-joyo-kanji";
  version = "0.0.2";

  # Upstream has no tags and no lockfile, and building it needs
  # textlint-scripts 1 (Babel 6). Use the npm tarball, which ships the built
  # lib/, with a lockfile vendored here.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-joyo-kanji/-/textlint-rule-joyo-kanji-${finalAttrs.version}.tgz";
    hash = "sha256-zNZXeX7Nzp43ew6n2XBKHCCXAAgF8aQYcVnwKpDc+WQ=";
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

  npmDepsHash = "sha256-exq3fPVWo9iLDjguTLNNwNi6Csy9UzRspncyFI+Y/+w=";

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
    description = "Textlint rule that checks that kanji are jōyō kanji";
    homepage = "https://github.com/kongou-ae/textlint-rule-joyo-kanji";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
