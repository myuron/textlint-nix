{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  nodejs,
  textlint,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "textlint-rule-preset-ja-spacing";
  version = "2.4.3";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-preset-ja-spacing";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M27qhjIHMcKbuPAh523Pi5IB5BD0VWawh84kUyLcKvg=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-AfbYACqYBvfsKzhryQabXQQmera19N/UH67sR5kbihM=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    nodejs
  ];

  # Upstream is a yarn workspaces monorepo: the preset and the rules it bundles
  # live in packages/* and are linked into the root node_modules. The root
  # package.json has no name, so yarnInstallHook cannot be used. Install the
  # whole workspace so that node_modules/textlint-rule-preset-ja-spacing (a link
  # to ../packages/textlint-rule-preset-ja-spacing) resolves.
  installPhase = ''
    runHook preInstall

    yarn install \
      --force \
      --frozen-lockfile \
      --ignore-engines \
      --ignore-platform \
      --ignore-scripts \
      --no-progress \
      --non-interactive \
      --offline \
      --production=true

    mkdir -p $out/lib
    cp -r . $out/lib

    runHook postInstall
  '';

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "スペース周りのスタイルを扱うtextlintルールプリセット";
    homepage = "https://github.com/textlint-ja/textlint-rule-preset-ja-spacing";
    changelog = "https://github.com/textlint-ja/textlint-rule-preset-ja-spacing/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
