{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
  textlint-rule-max-comma,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-plugin-org";
  version = "0.3.7";

  src = fetchFromGitHub {
    owner = "kijimaD";
    repo = "textlint-plugin-org";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BW+b09nv9Mzl3cUcOOpHoRz8tGLxuGGo4UCY6kdUlXA=";
  };

  npmDepsHash = "sha256-J1ksstPED7FwB80N4CzfZ1i2xc3Wmu7s4T3acOrWA9s=";

  passthru.tests = textlint.testPackages {
    inherit (finalAttrs) pname;
    rule = textlint-rule-max-comma;
    plugin = finalAttrs.finalPackage;
    testFile = ./test.org;
  };

  meta = {
    description = "Org mode support for textlint";
    homepage = "https://github.com/kijimaD/textlint-plugin-org";
    changelog = "https://github.com/kijimaD/textlint-plugin-org/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    inherit (textlint.meta) platforms;
  };
})
