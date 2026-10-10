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
  pname = "textlint-rule-no-filler";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-no-filler";
    tag = "v${finalAttrs.version}";
    hash = "sha256-t4HKHYShO1tQ605JMun2NnOvTf/utAahVQXZOQB5JL0=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-F401nUHD4VeskY6LNGmV6y0yb8v5gwo7ChkmkjS/lPw=";
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
          grep @textlint-ja/no-filler <(textlint --rule @textlint-ja/no-filler ${./test.md}) > $out
        '';
  };

  meta = {
    description = "「ええと」「あの」「まあ」などのフィラー（つなぎ表現）を禁止するtextlintルール";
    homepage = "https://github.com/textlint-ja/textlint-rule-no-filler";
    changelog = "https://github.com/textlint-ja/textlint-rule-no-filler/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
