# textlint-nix

[textlint](https://github.com/textlint/textlint)とそのpluginをNixで一元管理するためのflakeです。

textlint-nixをプロジェクトの`flake.nix`のinputsに加え、使いたいpluginを`plugins.<name>.enable = true;`で有効化すると、それらを組み込んだ`textlint`コマンドが手に入ります。`package.json`や`node_modules`は不要です。

この文書では、ルール(`textlint-rule-*`)やplugin(`textlint-plugin-*`)など、textlintを拡張するパッケージをまとめて「plugin」と呼びます。

## 使い方

### 1. flakeのinputsに追加する

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

### 2. `mkTextlint`でpluginを有効化する

`textlint-nix.lib.mkTextlint`は、有効化したpluginを組み込んだtextlintのpackageを返します。devShellに入れる例です。手順1と同じ`flake.nix`に、`inputs`に続けて`outputs`を書きます。

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

### 3. `.textlintrc.json`でルールを設定する

pluginを有効化しただけではルールは適用されません。通常のtextlintと同じく、プロジェクトの`.textlintrc.json`で使うルールを指定します。`textlint-rule-*`の場合、ルール名はplugin名から`textlint-rule-`を除いたものです。

```json
{
  "rules": {
    "no-hankaku-kana": true,
    "max-comma": true
  }
}
```

presetと`textlint-plugin-*`は指定のしかたが異なります。

- `textlint-rule-preset-*`は、`"rules": { "preset-ja-technical-writing": true }`のように`preset-`を付けたまま指定します。
- `textlint-plugin-*`は、`"plugins": ["latex2e"]`のように、`textlint-plugin-`を除いた名前を`plugins`に指定します。
- `textlint-rule-prh`は、`rulePaths`で辞書を指定しないと何も報告しません。

### 4. 実行する

```console
$ nix develop
$ textlint README.md
```

動作する一式は[`example/`](./example)にあります。

## 利用できるplugin

`plugins.<name>`の`<name>`に指定できるのは、textlint-nixがパッケージしているplugin、つまり[`pkgs/`](./pkgs)以下のディレクトリ名だけです。nixpkgsにあるpluginも、textlint-nixでパッケージしたものだけが使えます。

textlint-nixがパッケージしているpluginは次のとおりです。

| plugin | 説明 |
| --- | --- |
| [`textlint-plugin-latex2e`](https://github.com/textlint/textlint-plugin-latex2e) | LaTeX2εの文書をtextlintで扱えるようにする |
| [`textlint-plugin-org`](https://github.com/kijimaD/textlint-plugin-org) | Org modeの文書をtextlintで扱えるようにする |
| [`textlint-rule-abbr-within-parentheses`](https://github.com/azu/textlint-rule-abbr-within-parentheses) | 略語を括弧内に書いているかを確認する |
| [`textlint-rule-alex`](https://github.com/textlint-rule/textlint-rule-alex) | alexで配慮を欠く英語表現を検出する |
| [`textlint-rule-common-misspellings`](https://github.com/io-monad/textlint-rule-common-misspellings) | 英語のよくある綴り間違いを検出する |
| [`textlint-rule-diacritics`](https://github.com/sapegin/textlint-rule-diacritics) | ダイアクリティカルマークの付け忘れを検出する |
| [`textlint-rule-en-max-word-count`](https://github.com/textlint-rule/textlint-rule-en-max-word-count) | 英語の1文の単語数を制限する |
| [`textlint-rule-max-comma`](https://github.com/textlint-rule/textlint-rule-max-comma) | 1文中のカンマ(`,`)の数を制限する |
| [`textlint-rule-no-hankaku-kana`](https://github.com/textlint-ja/textlint-rule-no-hankaku-kana) | 半角カタカナの使用を禁止する |
| [`textlint-rule-no-start-duplicated-conjunction`](https://github.com/textlint-rule/textlint-rule-no-start-duplicated-conjunction) | 同じ接続詞で始まる文の繰り返しを検出する |
| [`textlint-rule-period-in-list-item`](https://github.com/textlint-rule/textlint-rule-period-in-list-item) | リスト項目の末尾のピリオドの有無を揃える |
| [`textlint-rule-preset-ai-words-ja`](https://github.com/p1ass/textlint-rule-preset-ai-words-ja) | AIが書いた日本語に多い表現を検出するプリセット |
| [`textlint-rule-preset-ja-spacing`](https://github.com/textlint-ja/textlint-rule-preset-ja-spacing) | 日本語のスペース周りのスタイルを扱うプリセット |
| [`textlint-rule-preset-ja-technical-writing`](https://github.com/textlint-ja/textlint-rule-preset-ja-technical-writing) | 技術文書向けのルールプリセット |
| [`textlint-rule-prh`](https://github.com/textlint-rule/textlint-rule-prh) | prhの辞書で表記ゆれを検出する |
| [`textlint-rule-stop-words`](https://github.com/sapegin/textlint-rule-stop-words) | 冗長な語や決まり文句を検出する |
| [`textlint-rule-terminology`](https://github.com/sapegin/textlint-rule-terminology) | 技術用語の表記を揃える |
| [`textlint-rule-unexpanded-acronym`](https://github.com/textlint-rule/textlint-rule-unexpanded-acronym) | 展開されていない頭字語を検出する |
| [`textlint-rule-write-good`](https://github.com/textlint-rule/textlint-rule-write-good) | write-goodで英語の文体を確認する |

存在しない名前を指定すると、評価時にエラーになります。

使いたいpluginがない場合は、Issueで要望するか、[CONTRIBUTING.md](./CONTRIBUTING.md)の「pluginを追加する」を参考にPull Requestを送ってください。

## `mkTextlint`の引数

| 引数 | 説明 |
| --- | --- |
| `pkgs` | 利用するnixpkgs。textlint本体はここから取られる |
| `plugins.<name>.enable` | pluginを有効化するかどうか。既定値は`false` |

textlint本体には`pkgs.textlint`を使い、pluginの組み込みには`pkgs.textlint.withPackages`を使います。`withPackages`を持たない古いnixpkgsでは動作しません。

## pluginを個別に使う

textlint-nixがパッケージしているpluginは`packages.<system>.<name>`としても公開しています。`mkTextlint`を使わず、自分で`withPackages`に渡すこともできます。

```nix
pkgs.textlint.withPackages [
  textlint-nix.packages.${pkgs.stdenv.hostPlatform.system}.textlint-rule-no-hankaku-kana
]
```
