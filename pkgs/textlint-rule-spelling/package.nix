{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  jq,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-spelling";
  version = "0.3.0-unstable-2020-11-26";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "tani";
    repo = "textlint-rule-spelling";
    rev = "c206d3f34e1fe14dff261275aa23caf6b5157883";
    hash = "sha256-y5u/s9HTIiK6CNGfvhZt+BWulRpkktsQztWfkWCwYMY=";
  };

  # The rule loads its dictionary with require.resolve("dictionary-<language>")
  # and defaults to "en", but upstream only has dictionary-en as a
  # devDependency. Move it to dependencies to keep it in the production
  # install, so that the default configuration works. postPatch also runs in
  # the npmDeps fetcher, where nativeBuildInputs are not available, hence the
  # absolute path to jq.
  postPatch = ''
    ${lib.getExe jq} '.dependencies."dictionary-en" = .devDependencies."dictionary-en" | del(.devDependencies."dictionary-en")' package.json > package.json.tmp
    mv package.json.tmp package.json
  '';

  npmDepsHash = "sha256-W0nX4KeNNt/oQTJuw6707VKu6r+Q1cEKh1KCUxJ6zVk=";

  # The lockfile (lockfileVersion 1) does not satisfy the textlint peer
  # dependency, which npm would otherwise try to fetch.
  npmFlags = [ "--legacy-peer-deps" ];

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule to check spelling with nspell";
    homepage = "https://github.com/tani/textlint-rule-spelling";
    license = lib.licenses.gpl3Plus;
    inherit (textlint.meta) platforms;
  };
})
