{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  textlint,
  runCommand,
}:

buildNpmPackage (finalAttrs: {
  pname = "textlint-rule-allowed-uris";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "lumirlumir";
    repo = "npm-textlint-rule-allowed-uris";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mQjpbSXsR/1C+2tarS4gf+3+YkE/KPnI30mtw89ivWU=";
  };

  npmDepsHash = "sha256-4VVPylSlhlS5cU7z0hBqv0+Y/qkFtfxPltQUPW3OSw0=";

  # npm prune runs the prepare script, which calls husky. husky is a
  # devDependency that the prune itself removes, and there is no git repository
  # to install hooks into.
  npmPruneFlags = [ "--ignore-scripts" ];

  # By default every URI is allowed, so the rule reports nothing and
  # textlint.testPackages (which only passes --rule) cannot be used. An empty
  # list of allowed link patterns makes every link a violation.
  passthru.tests = {
    "${finalAttrs.pname}-test" =
      runCommand "${finalAttrs.pname}-test"
        { nativeBuildInputs = [ (textlint.withPackages [ finalAttrs.finalPackage ]) ]; }
        ''
          grep allowed-uris <(textlint --config ${./textlintrc} ${./test.md}) > $out
        '';
  };

  meta = {
    description = "Textlint rule for checking allowed URIs in links and images of Markdown";
    homepage = "https://github.com/lumirlumir/npm-textlint-rule-allowed-uris";
    changelog = "https://github.com/lumirlumir/npm-textlint-rule-allowed-uris/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
