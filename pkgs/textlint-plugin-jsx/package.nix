{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
  textlint-rule-terminology,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-plugin-jsx";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "hata6502";
    repo = "textlint-plugin-jsx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wSG3v0RVOnm8duStsWOacW+zNu7tVkIWI+0CSxM7jWg=";
  };

  npmDepsHash = "sha256-gG4YtOWm57HnzkDlk6OGjhNub3BNhnJ5Fw+siieEvRA=";

  # The plugin imports typescript at runtime but declares it only as a peer
  # (and dev) dependency, so npmInstallHook prunes it and textlint fails with
  # "Failed to load packages". Keep the version pinned by the lockfile:
  # textlint.withPackages cannot supply peers, and typescript in nixpkgs (7.x)
  # no longer ships the JavaScript API the plugin uses.
  preInstall = ''
    cp -r node_modules/typescript "$TMPDIR/typescript"
  '';

  postInstall = ''
    cp -r "$TMPDIR/typescript" "$out/lib/node_modules/textlint-plugin-jsx/node_modules/typescript"
  '';

  # The plugin emits Str nodes without a parent Paragraph, so rules that work
  # on paragraphs or sentences (e.g. max-comma) report nothing. terminology
  # checks Str nodes directly.
  passthru.tests = textlint.testPackages {
    inherit (finalAttrs) pname;
    rule = textlint-rule-terminology;
    plugin = finalAttrs.finalPackage;
    testFile = ./test.tsx;
  };

  meta = {
    description = "JSX and TSX support for textlint";
    homepage = "https://github.com/hata6502/textlint-plugin-jsx";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
