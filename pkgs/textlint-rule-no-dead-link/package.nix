{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_10,
  nodejs,
  textlint,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "textlint-rule-no-dead-link";
  version = "6.2.3";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-no-dead-link";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hueoW7N2pjvDIurRQ+sI+URXBQYlgG7jg1DDdN4oBkY=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 4;
    hash = "sha256-a0KxX4lwgJyJlxijv1Fhpidlstz7QOn/mf5q397aVHQ=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm_10
  ];

  buildPhase = ''
    runHook preBuild

    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pnpm install --offline --frozen-lockfile --ignore-scripts --prod
    mkdir -p $out/lib/node_modules/textlint-rule-no-dead-link
    cp -r lib node_modules package.json $out/lib/node_modules/textlint-rule-no-dead-link

    runHook postInstall
  '';

  # The sandbox has no network. A relative link to a missing file is checked
  # on the filesystem and reported without one.
  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule to check if all links are alive";
    homepage = "https://github.com/textlint-rule/textlint-rule-no-dead-link";
    changelog = "https://github.com/textlint-rule/textlint-rule-no-dead-link/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
