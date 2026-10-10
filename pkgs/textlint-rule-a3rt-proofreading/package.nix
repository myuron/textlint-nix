{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
  runCommand,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-a3rt-proofreading";
  version = "1.0.2-unstable-2018-03-07";

  # Upstream has no tags.
  src = fetchFromGitHub {
    owner = "sters";
    repo = "textlint-rule-a3rt-proofreading";
    rev = "82821b307e0ab27512237852fe77d194b0e5f183";
    hash = "sha256-svpJ17jMWOhqPpED7N3z3/Nl7GSeLNzqOJ+OIlk3mu8=";
  };

  npmDepsHash = "sha256-xZhIwyxroOccweaTJFvR8nTZHq6F0BXyxCtQFc4Uafk=";

  # The install script (node-gyp) of the devDependency utf-8-validate does not
  # build with the current Node.js.
  npmRebuildFlags = [ "--ignore-scripts" ];

  # The rule sends every paragraph to the A3RT Proofreading API, which needs an
  # API key and network access, and whose host no longer resolves. Check
  # instead that textlint loads the rule and runs it far enough to hit its own
  # check for the API key.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          unset A3RT_APIKEY
          grep -F "Error while loading rule 'a3rt-proofreading': A3RT apikey is not set." \
            <(textlint --rule a3rt-proofreading ${./test.md} 2>&1) > $out
        '';
  };

  meta = {
    description = "Textlint rule that proofreads Japanese with the A3RT Proofreading API";
    homepage = "https://github.com/sters/textlint-rule-a3rt-proofreading";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
