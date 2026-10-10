{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-max-kanji-continuous-len";
  version = "1.1.1";

  # Upstream has no tag and no lockfile for 1.1.1, and building it needs
  # Babel 6. Use the npm tarball, which ships the built lib/, with a lockfile
  # vendored here.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-rule-max-kanji-continuous-len/-/textlint-rule-max-kanji-continuous-len-${finalAttrs.version}.tgz";
    hash = "sha256-U13ne+M7nrOEgpUnS8PsXOoWAUWHhyFb8M24HGe/MaA=";
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

  npmDepsHash = "sha256-PPHY7k4jzidvN00/6WaL6q56c2/XwwyaLXOv40aX1tM=";

  dontNpmBuild = true;

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that limits the length of consecutive kanji";
    homepage = "https://github.com/textlint-ja/textlint-rule-max-kanji-continuous-len";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
