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
  pname = "textlint-rule-no-hoso-kinshi-yogo";
  version = "1.3.2-unstable-2021-04-24";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "hata6502";
    repo = "textlint-rule-no-hoso-kinshi-yogo";
    rev = "7ce90d03fea0dc978f3cf7ae53b396a152848cc5";
    hash = "sha256-nFb8ZDjEpHtdJsXZb3XYyPq5EP2lTf4lDkZtYIFqNV8=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-Yvepem2g8bw3igeKnCnLQClCulMhZaq8F7ftUJu93i0=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];
  # At run time the rule downloads its dictionary from monoroch.net and caches
  # it in os.tmpdir() for seven days. The sandbox has no network access, so put
  # a minimal dictionary there as a fresh cache first.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          cp ${./housouKinshiYougo.xml} "$TMPDIR/housouKinshiYougo.xml"
          grep no-hoso-kinshi-yogo <(textlint --rule no-hoso-kinshi-yogo ${./test.md}) > $out
        '';
  };

  meta = {
    description = "Textlint rule that checks words unsuitable for broadcasting (放送禁止用語)";
    homepage = "https://github.com/hata6502/textlint-rule-no-hoso-kinshi-yogo";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
