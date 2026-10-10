{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  nodejs,
  textlint,
  runCommand,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "textlint-rule-require-header-id";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-require-header-id";
    tag = finalAttrs.version;
    hash = "sha256-bJsV8e/CzrSqc4qTzOY6Wtc1rCeqVz/Nhl9vGaVXSAo=";
  };

  # yarn.lock has one http:// URL, which fetchYarnDeps cannot download.
  postPatch = ''
    substituteInPlace yarn.lock \
      --replace-fail "http://registry.npmjs.org/" "https://registry.yarnpkg.com/"
  '';

  yarnOfflineCache = fetchYarnDeps {
    inherit (finalAttrs) src postPatch;
    hash = "sha256-CEjdWBF3lN1YIWzSZdT5sGjCzOqY5uMxkw0W4+Cnx7w=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  # testPackages derives the rule name from pname, which cannot hold a scoped
  # name, so run textlint with the scoped rule name directly.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          grep @textlint-rule/require-header-id <(textlint --rule @textlint-rule/require-header-id ${./test.md}) > $out
        '';
  };

  meta = {
    description = "Textlint rule that require {#id} for each headers";
    homepage = "https://github.com/textlint-rule/textlint-rule-require-header-id";
    changelog = "https://github.com/textlint-rule/textlint-rule-require-header-id/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
