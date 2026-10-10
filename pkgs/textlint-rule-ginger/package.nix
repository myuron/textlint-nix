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
  pname = "textlint-rule-ginger";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-ginger";
    tag = finalAttrs.version;
    hash = "sha256-uhqBUh9gAb+Q8PP0trBjJ28RA0HhMUzz0G4A2maqZas=";
  };

  # Some entries of yarn.lock are resolved over plain http, which fetchYarnDeps
  # cannot download. The fetcher gets the same postPatch, so that its copy of
  # yarn.lock matches the one yarnConfigHook sees.
  postPatch = ''
    substituteInPlace yarn.lock \
      --replace-fail "http://registry.npmjs.org/" "https://registry.npmjs.org/"
  '';

  yarnOfflineCache = fetchYarnDeps {
    inherit (finalAttrs) src postPatch;
    hash = "sha256-av2k8eekiySG4u5S8eA9WV5ilyxbkN+XFyFIPdZ/Egs=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  # gingerbread sends every paragraph to the Ginger API, which needs network
  # access and has been retired: the endpoint now redirects to a stub that
  # carries no corrections, so the rule reports nothing. Point the request at a
  # closed local port, so that the result does not depend on the sandbox, and
  # check that textlint loads the rule and runs it far enough to call the API.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          export http_proxy=http://127.0.0.1:9
          grep -F "Couldn't connect to API endpoint (http://services.gingersoftware.com/Ginger/correct/json/GingerTheText)" \
            <(textlint --rule ginger ${./test.md} 2>&1) > $out
        '';
  };

  meta = {
    description = "Textlint rule to check English grammar with Ginger Proofreading";
    homepage = "https://github.com/textlint-rule/textlint-rule-ginger";
    changelog = "https://github.com/textlint-rule/textlint-rule-ginger/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
