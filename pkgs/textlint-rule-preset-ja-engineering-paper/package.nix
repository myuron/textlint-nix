{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-preset-ja-engineering-paper";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "kn1cht";
    repo = "textlint-rule-preset-ja-engineering-paper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FzBT9BxSue6TmNL95jHQBaHhNHCs+6xLBu+u/FiFEGw=";
  };

  npmDepsHash = "sha256-CwcY2IoEsSALQs3kZ/8zLrzKcidpiWFcMkmHrdJLOrg=";

  # The preset points prh at its dictionary with a path relative to the
  # node_modules/ of the project that uses it, which does not exist with Nix:
  # textlint then fails to load the preset. Point it at the copy in the store.
  # This is done after the install rather than in postPatch, which would also
  # run in the npmDeps fetcher.
  postInstall = ''
    substituteInPlace $out/lib/node_modules/textlint-rule-preset-ja-engineering-paper/lib/index.js \
      --replace-fail "node_modules/textlint-rule-preset-ja-engineering-paper/src/dict/prh-rules.yml" "$out/lib/node_modules/textlint-rule-preset-ja-engineering-paper/src/dict/prh-rules.yml"
  '';

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule preset for Japanese academic papers of engineering";
    homepage = "https://github.com/kn1cht/textlint-rule-preset-ja-engineering-paper";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
