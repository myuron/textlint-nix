# textlint-nix

[日本語](./README-jp.md)

A flake for managing [textlint](https://github.com/textlint/textlint) and its plugins in one place with Nix.

Add textlint-nix to the inputs of your project's `flake.nix` and enable the plugins you want with `plugins.<name>.enable = true;` to get a `textlint` command with those plugins built in. No `package.json` or `node_modules` is needed.

In this document, "plugin" refers to any package that extends textlint, including rules (`textlint-rule-*`) and plugins (`textlint-plugin-*`).

## Usage

### 1. Add it to your flake inputs

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    textlint-nix = {
      url = "github:myuron/textlint-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

### 2. Enable plugins with `mkTextlint`

`textlint-nix.lib.mkTextlint` returns a textlint package with the enabled plugins built in. The example below adds it to a devShell. Write `outputs` after `inputs` in the same `flake.nix` as in step 1.

```nix
{
  outputs =
    { nixpkgs, textlint-nix, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = [
            (textlint-nix.lib.mkTextlint {
              inherit pkgs;
              plugins.textlint-rule-no-hankaku-kana.enable = true;
              plugins.textlint-rule-max-comma.enable = true;
            })
          ];
        };
      });
    };
}
```

### 3. Configure rules in `.textlintrc.json`

Enabling a plugin does not apply its rules. As with regular textlint, specify the rules to use in your project's `.textlintrc.json`. For `textlint-rule-*` packages, the rule name is the plugin name without the `textlint-rule-` prefix.

```json
{
  "rules": {
    "no-hankaku-kana": true,
    "max-comma": true
  }
}
```

Presets and `textlint-plugin-*` packages are specified differently.

- For `textlint-rule-preset-*`, keep the `preset-` prefix, as in `"rules": { "preset-ja-technical-writing": true }`.
- For `textlint-plugin-*`, list the name without the `textlint-plugin-` prefix under `plugins`, as in `"plugins": ["latex2e"]`.
- `textlint-rule-prh` reports nothing unless you point `rulePaths` at a dictionary.

### 4. Run it

```console
$ nix develop
$ textlint README.md
```

A complete working setup is in [`example/`](./example).

## Available plugins

The `<name>` in `plugins.<name>` must be a plugin packaged by textlint-nix, that is, the name of a directory under [`pkgs/`](./pkgs). Plugins that exist in nixpkgs are also available only if textlint-nix packages them.

textlint-nix packages the following plugins.

| plugin | Description |
| --- | --- |
| [`textlint-plugin-latex2e`](https://github.com/textlint/textlint-plugin-latex2e) | Lets textlint handle LaTeX2ε documents |
| [`textlint-plugin-org`](https://github.com/kijimaD/textlint-plugin-org) | Lets textlint handle Org mode documents |
| [`textlint-rule-abbr-within-parentheses`](https://github.com/azu/textlint-rule-abbr-within-parentheses) | Checks that abbreviations are written within parentheses |
| [`textlint-rule-alex`](https://github.com/textlint-rule/textlint-rule-alex) | Detects insensitive, inconsiderate English writing with alex |
| [`textlint-rule-common-misspellings`](https://github.com/io-monad/textlint-rule-common-misspellings) | Detects common English misspellings |
| [`textlint-rule-diacritics`](https://github.com/sapegin/textlint-rule-diacritics) | Detects missing diacritics |
| [`textlint-rule-en-max-word-count`](https://github.com/textlint-rule/textlint-rule-en-max-word-count) | Limits the number of words in an English sentence |
| [`textlint-rule-max-comma`](https://github.com/textlint-rule/textlint-rule-max-comma) | Limits the number of commas (`,`) in a sentence |
| [`textlint-rule-no-hankaku-kana`](https://github.com/textlint-ja/textlint-rule-no-hankaku-kana) | Disallows half-width katakana |
| [`textlint-rule-no-start-duplicated-conjunction`](https://github.com/textlint-rule/textlint-rule-no-start-duplicated-conjunction) | Detects consecutive sentences that start with the same conjunction |
| [`textlint-rule-period-in-list-item`](https://github.com/textlint-rule/textlint-rule-period-in-list-item) | Enforces the presence or absence of a period at the end of list items |
| [`textlint-rule-preset-ai-words-ja`](https://github.com/p1ass/textlint-rule-preset-ai-words-ja) | Preset that detects expressions common in AI-generated Japanese |
| [`textlint-rule-preset-ja-spacing`](https://github.com/textlint-ja/textlint-rule-preset-ja-spacing) | Preset for spacing style in Japanese text |
| [`textlint-rule-preset-ja-technical-writing`](https://github.com/textlint-ja/textlint-rule-preset-ja-technical-writing) | Rule preset for Japanese technical writing |
| [`textlint-rule-prh`](https://github.com/textlint-rule/textlint-rule-prh) | Detects inconsistent spelling with prh dictionaries |
| [`textlint-rule-stop-words`](https://github.com/sapegin/textlint-rule-stop-words) | Detects filler words and clichés |
| [`textlint-rule-terminology`](https://github.com/sapegin/textlint-rule-terminology) | Enforces the correct spelling of technical terms |
| [`textlint-rule-unexpanded-acronym`](https://github.com/textlint-rule/textlint-rule-unexpanded-acronym) | Detects acronyms that are never expanded |
| [`textlint-rule-write-good`](https://github.com/textlint-rule/textlint-rule-write-good) | Checks English style with write-good |

Specifying a name that does not exist causes an error at evaluation time.

If the plugin you want is missing, request it in an issue, or send a pull request following the "pluginを追加する" (adding a plugin) section of [CONTRIBUTING.md](./CONTRIBUTING.md), which is written in Japanese.

## Arguments of `mkTextlint`

| Argument | Description |
| --- | --- |
| `pkgs` | The nixpkgs to use. textlint itself is taken from here |
| `plugins.<name>.enable` | Whether to enable the plugin. Defaults to `false` |

textlint itself comes from `pkgs.textlint`, and plugins are built in with `pkgs.textlint.withPackages`. Older nixpkgs revisions without `withPackages` are not supported.

## Using plugins individually

The plugins packaged by textlint-nix are also exposed as `packages.<system>.<name>`. You can pass them to `withPackages` yourself instead of using `mkTextlint`.

```nix
pkgs.textlint.withPackages [
  textlint-nix.packages.${pkgs.stdenv.hostPlatform.system}.textlint-rule-no-hankaku-kana
]
```
