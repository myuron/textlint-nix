{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_11,
  nodejs,
  textlint,
  runCommand,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "slopless";
  version = "0.2.40";

  src = fetchFromGitHub {
    owner = "berelevant-ai";
    repo = "slopless";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GSRZC2zyFRHfo2hCnNqHWvG8j90vbdARrXUkScvlGis=";
  };

  # Upstream pins pnpm 11 in packageManager.
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_11;
    fetcherVersion = 4;
    hash = "sha256-0aXA3SD6XxBBTZC56z6u40o+x9kJ+i4nyxFIraUUGuw=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm_11
  ];

  buildPhase = ''
    runHook preBuild

    pnpm build

    runHook postBuild
  '';

  # Without removing node_modules first, the devDependencies stay in
  # node_modules/.pnpm after the production install.
  installPhase = ''
    runHook preInstall

    rm -r node_modules
    pnpm install --offline --frozen-lockfile --ignore-scripts --prod
    mkdir -p $out/lib/node_modules/slopless
    cp -r dist node_modules package.json $out/lib/node_modules/slopless

    runHook postInstall
  '';

  # The npm name has no textlint-rule-preset- prefix, from which testPackages
  # derives the name and --preset, so run textlint with --preset directly.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          grep slopless/ <(textlint --preset slopless ${./test.md}) > $out
        '';
  };

  meta = {
    description = "Textlint preset that catches AI-slop patterns in English prose";
    homepage = "https://github.com/berelevant-ai/slopless";
    changelog = "https://github.com/berelevant-ai/slopless/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
