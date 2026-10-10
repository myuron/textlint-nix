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
  pname = "textlint-rule-no-insert-dropping-sa";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-no-insert-dropping-sa";
    tag = "v${finalAttrs.version}";
    hash = "sha256-msLbWDuVWuB4vyqGaQWtzBQLCz15/4k3XTv7Lsit6lU=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-qtGJr6sCR0bazVKjasNnMFii3SbxaX7G0sDklddVzcY=";
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
          grep @textlint-ja/no-insert-dropping-sa <(textlint --rule @textlint-ja/no-insert-dropping-sa ${./test.md}) > $out
        '';
  };

  meta = {
    description = "サ抜き、サ入れ表現の誤用をチェックするtextlintルール";
    homepage = "https://github.com/textlint-ja/textlint-rule-no-insert-dropping-sa";
    changelog = "https://github.com/textlint-ja/textlint-rule-no-insert-dropping-sa/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
