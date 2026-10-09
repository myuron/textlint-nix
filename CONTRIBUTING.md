# Contributing

Thank you for your interest in contributing to textlint-nix. All contributions are welcome: adding plugins, updating existing plugins, fixing bugs, improving the documentation, and so on.

See [README.md](./README.md) for usage. This document summarizes what you need to know when making changes.

## Development environment

You need [Nix](https://nixos.org/) with flakes enabled. All other tools are included in the devShell.

```console
$ nix develop
```

If you use [direnv](https://direnv.net/), `direnv allow` puts you in the devShell automatically.

## Repository layout

| Path | Contents |
| --- | --- |
| `flake.nix` | The flake outputs (`lib`, `packages`, `checks`, `formatter`, `devShells`) |
| `lib/default.nix` | The user-facing `mkTextlint` |
| `modules/textlint.nix` | The module that defines `plugins.<name>.enable` and passes the enabled plugins to `textlint.withPackages` |
| `pkgs/<name>/package.nix` | The derivation of a plugin packaged by textlint-nix |
| `pkgs/<name>/test.md` | The test document for that plugin |
| `tests/` | The checks run by `nix flake check` |
| `example/` | An example project that uses textlint-nix |

## Design principles

Before proposing a change, please review the following principles.

- The user-facing interface is the module option (`plugins.<name>.enable = true;`).
- Plugins are not taken from nixpkgs. Plugins that already exist in nixpkgs (`textlint-rule-*` / `textlint-plugin-*`) are also packaged in `pkgs/` of this repository. textlint itself (`textlint.withPackages`) comes from nixpkgs.
- Each plugin gets its own derivation. If upstream uses npm (`package-lock.json`), write it with `buildNpmPackage`. Only if upstream uses yarn / pnpm, use `stdenv.mkDerivation` with `fetchYarnDeps` / `fetchPnpmDeps` instead of `buildNpmPackage`.
- A plugin derivation must be in a form that can be passed to nixpkgs' `textlint.withPackages` as is.
- The module stays a thin layer that collects the enabled plugins and passes them to `withPackages`. Plugin-specific quirks are handled in the derivation.

## Adding a plugin

### 1. Check upstream

- Make sure `pkgs/` has no directory with the same name. Even if nixpkgs has the same plugin, it is packaged in textlint-nix.
- In the upstream repository, check the tag of the release you are packaging and the kind of lockfile (`package-lock.json` / `yarn.lock` / `pnpm-lock.yaml`).

### 2. Write the derivation

Create `pkgs/<name>/package.nix`. `<name>` must match the npm package name (`textlint-rule-*` / `textlint-plugin-*`). This directory name becomes `plugins.<name>` and `packages.<system>.<name>` as is. `pkgs/default.nix` picks up directories automatically, so you do not need to register the plugin in a list.

Use the existing [`pkgs/textlint-rule-no-hankaku-kana/package.nix`](./pkgs/textlint-rule-no-hankaku-kana/package.nix) as a reference. If upstream uses yarn, use [`pkgs/textlint-rule-max-comma/package.nix`](./pkgs/textlint-rule-max-comma/package.nix) instead. It combines `stdenv.mkDerivation` with the yarn hooks (`yarnConfigHook` and others) rather than using `buildNpmPackage`.

For less common cases, use these as a reference.

- Upstream uses pnpm: [`pkgs/textlint-rule-preset-ai-words-ja/package.nix`](./pkgs/textlint-rule-preset-ai-words-ja/package.nix)
- Upstream is a monorepo (yarn workspaces): [`pkgs/textlint-rule-preset-ja-spacing/package.nix`](./pkgs/textlint-rule-preset-ja-spacing/package.nix)
- Upstream has no lockfile, so one is vendored next to `package.nix`: [`pkgs/textlint-rule-common-misspellings/package.nix`](./pkgs/textlint-rule-common-misspellings/package.nix)
- Test of a `textlint-plugin-*`, which takes the `plugin` argument and another rule under `pkgs/`: [`pkgs/textlint-plugin-latex2e/package.nix`](./pkgs/textlint-plugin-latex2e/package.nix)
- Test of a rule that reports nothing without configuration, written as a dedicated `runCommand`: [`pkgs/textlint-rule-prh/package.nix`](./pkgs/textlint-rule-prh/package.nix)

A plugin name listed in the arguments of `package.nix` resolves to the one under `pkgs/`, not the one in nixpkgs.

- `version` and the tag of `src` must point to a release that actually exists upstream. Only when upstream has no matching tag, pin `rev` instead and set the version to `<version>-unstable-<date>`.
- For the `hash` of `src` and the dependency hash (`npmDepsHash`, or the `hash` of `fetchYarnDeps` for yarn), first set `lib.fakeHash`, build, and replace it with the actual value shown in the error. Do not reuse values from other plugins.
- Set `description`, `homepage`, `changelog`, and `license` in `meta` according to upstream. For `platforms`, use `inherit (textlint.meta) platforms;` as in the reference.

### 3. Add a test

Every plugin under `pkgs/` must have `passthru.tests`. Without it, `nix flake check` fails.

```nix
passthru.tests = textlint.testPackages {
  rule = finalAttrs.finalPackage;
  testFile = ./test.md;
};
```

In `pkgs/<name>/test.md`, write text that violates the rule. The test checks that the textlint output contains the rule name.

`textlint-rule-preset-*` works the same way. `testPackages` detects it from the name and runs it with `--preset`.

A `textlint-plugin-*` reports nothing on its own, so test it in combination with a rule. Pass the plugin itself as `plugin` and the rule to combine it with as `rule`, and set `pname` explicitly. For `testFile`, provide a file in the format the plugin handles (such as `test.tex`) that violates `rule`.

```nix
passthru.tests = textlint.testPackages {
  inherit (finalAttrs) pname;
  plugin = finalAttrs.finalPackage;
  rule = textlint-rule-max-comma;
  testFile = ./test.tex;
};
```

### 4. Build and verify

Flakes only see files tracked by git. Run `git add` on new files first. If `pkgs/<name>/` is left untracked, the flake cannot see that directory. `nix build .#<name>` fails with an error saying the flake does not provide that attribute, and `nix flake check` succeeds without checking the plugin you added. Even if the check passes, make sure the test of the plugin you added actually ran.

```console
$ git add pkgs/<name>
$ nix build .#<name>
$ nix flake check
```

### 5. Update the README

Add a row for the new plugin to the "Available plugins" table in [README.md](./README.md).

## Updating an existing plugin

When you bump `version`, always update the `hash` of `src` and the dependency hash (`npmDepsHash`, or the `hash` of `fetchYarnDeps` for yarn) as well. With stale hashes, the build still passes on a machine that has already built the plugin, because of caching. The reliable way is to reset both to `lib.fakeHash` and rebuild.

## Changing the module or the flake

Make sure the change keeps the `plugins.<name>.enable` interface and follows the design principles above. The module wiring is verified by `tests/mk-textlint.nix`. If you change the behavior, update this test as well.

The supported systems are `x86_64-linux`, `aarch64-linux`, and `aarch64-darwin`. Avoid code that depends on a specific system.

## Formatting and checks

Run the following two commands before opening a pull request. CI verifies on all three systems that the code is formatted and runs `nix flake check`. CI fails if the code is not formatted.

```console
$ nix fmt
$ nix flake check
```

- `nix fmt` formats Nix code with nixfmt.
- `nix flake check` runs the statix and deadnix lints, the module tests, and the tests of each plugin.

Do not disable lints or weaken tests to make the checks pass.

## Commits and pull requests

- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/) and are written in English (e.g. `feat: add textlint-rule-foo`, `fix: update npmDepsHash of textlint-rule-foo`).
- A pull request should contain changes for a single purpose. Do not include unrelated `flake.lock` updates.
- In the pull request description, describe what you changed and how you verified it (the commands you ran and their results).

## Issues

Bug reports and requests for new plugins are accepted as issues. For a bug, include the relevant part of your `flake.nix`, the command you ran, and the error output.
