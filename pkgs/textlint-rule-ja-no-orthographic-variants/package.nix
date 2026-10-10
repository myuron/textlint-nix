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
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "textlint-rule-ja-no-orthographic-variants";
  version = "2.0.0-unstable-2021-04-24";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-ja-no-orthographic-variants";
    rev = "024ecf07630182c7e70aa04595f971b430890939";
    hash = "sha256-oJatm5JGfmKPFqZS23lZDl6HWwcxETR2dII/nErwr3w=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-uIJHhz3NDMFNi8ZwN8Y9GQsIba1ppXkY5F7JgB4GUFQ=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  # The rule embeds the orthographic variant dictionary of NINJAL, whose
  # license (HTDIC-LICENSE) requires that the license document is copied along
  # with the data. It is not listed in "files" of package.json, so
  # yarnInstallHook does not install it.
  postInstall = ''
    cp HTDIC-LICENSE $out/lib/node_modules/${finalAttrs.pname}/
  '';

  passthru.tests = textlint.testPackages {
    rule = finalAttrs.finalPackage;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that checks orthographic variants (表記ゆれ) in Japanese";
    homepage = "https://github.com/textlint-ja/textlint-rule-ja-no-orthographic-variants";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
