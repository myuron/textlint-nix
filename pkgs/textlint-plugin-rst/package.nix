{
  lib,
  buildNpmPackage,
  fetchurl,
  fetchPypi,
  jq,
  python3Packages,
  textlint,
  textlint-rule-max-comma,
}:

let
  # The plugin shells out to rst2ast, which is provided by this Python package.
  # It is not in nixpkgs, and it is not a textlint plugin, so it is defined
  # here instead of in its own directory under pkgs/.
  docutils-ast-writer = python3Packages.buildPythonApplication (finalAttrs: {
    pname = "docutils-ast-writer";
    version = "0.1.2";
    pyproject = true;

    src = fetchPypi {
      inherit (finalAttrs) pname version;
      hash = "sha256-LGgPgTr/y7tjsD462o87eWO+ri+1hbZjnwu76p8PGKQ=";
    };

    # use_2to3 was removed from setuptools, so do by hand the only conversion
    # the code needs: without it the NameError on unicode / long is swallowed
    # and every node loses its attributes.
    postPatch = ''
      substituteInPlace setup.py \
        --replace-fail "use_2to3 = True" ""
      substituteInPlace rst2ast/writer.py \
        --replace-fail "bool, unicode, long," "bool,"
    '';

    build-system = [ python3Packages.setuptools ];

    dependencies = [ python3Packages.docutils ];

    pythonImportsCheck = [ "rst2ast" ];

    meta = {
      description = "AST Writer for docutils";
      homepage = "https://github.com/jimo1001/docutils-ast-writer";
      license = lib.licenses.mit;
      mainProgram = "rst2ast";
    };
  });
in
buildNpmPackage (finalAttrs: {
  pname = "textlint-plugin-rst";
  version = "0.1.1";

  # Upstream has no tags and no lockfile, and building it needs Babel 6. Use
  # the npm tarball, which ships the built lib/, with a lockfile vendored here.
  src = fetchurl {
    url = "https://registry.npmjs.org/textlint-plugin-rst/-/textlint-plugin-rst-${finalAttrs.version}.tgz";
    hash = "sha256-Ixd2tmz32SnJJXr/EByUdO2Fm9Ns4hiLJ5cAI2ztMpE=";
  };

  # package-lock.json was generated without devDependencies (they are only
  # needed to build lib/), so drop them from package.json to keep both in
  # sync. postPatch also runs in the npmDeps fetcher, where nativeBuildInputs
  # are not available, hence the absolute path to jq.
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-ufEhN1Qcp0f511mM3GnuhiGyfXVzU3EmsOb2HnzDwoU=";

  dontNpmBuild = true;

  # The plugin runs `rst2ast` from PATH. Point it at the store path so that it
  # works when only passed to textlint.withPackages. Done here rather than in
  # postPatch to keep the Python package out of the npmDeps fetcher.
  postInstall = ''
    substituteInPlace $out/lib/node_modules/textlint-plugin-rst/lib/rst-to-ast.js \
      --replace-fail '"rst2ast -q"' '"${lib.getExe docutils-ast-writer} -q"'
  '';

  passthru.tests = textlint.testPackages {
    inherit (finalAttrs) pname;
    rule = textlint-rule-max-comma;
    plugin = finalAttrs.finalPackage;
    testFile = ./test.rst;
  };

  meta = {
    description = "reStructuredText support for textlint";
    homepage = "https://github.com/jimo1001/textlint-plugin-rst";
    license = lib.licenses.mit;
    inherit (textlint.meta) platforms;
  };
})
