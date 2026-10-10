# textlint-nix

[textlint](https://github.com/textlint/textlint)とそのpluginをNixで一元管理するためのflakeです。

textlint-nixをプロジェクトの`flake.nix`のinputsに加え、使いたいpluginを`plugins.<name>.enable = true;`で有効化すると、それらを組み込んだ`textlint`コマンドが手に入ります。`package.json`や`node_modules`は不要です。

この文書では、ルール(`textlint-rule-*`)やfilter rule(`textlint-filter-rule-*`)、plugin(`textlint-plugin-*`)など、textlintを拡張するパッケージをまとめて「plugin」と呼びます。

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

preset、`textlint-filter-rule-*`、`textlint-plugin-*`は指定のしかたが異なります。

- `textlint-rule-preset-*`は、`"rules": { "preset-ja-technical-writing": true }`のように`preset-`を付けたまま指定します。
- `textlint-plugin-*`は、`"plugins": ["latex2e"]`のように、`textlint-plugin-`を除いた名前を`plugins`に指定します。
- `textlint-filter-rule-*`は、`"filters": { "comments": true }`のように、`textlint-filter-rule-`を除いた名前を`filters`に指定します。filter ruleは単体では何も報告せず、`rules`で指定したルールの報告を抑制します。
- `textlint-rule-prh`は、`rulePaths`で辞書を指定しないと何も報告しません。
- `textlint-plugin-satsuki`は、`textlint --plugin satsuki file.txt`のようにコマンドラインで指定したときだけ効きます。`.textlintrc.json`の`plugins`に書いても効きません。textlintが、同じ`.txt`を扱う組み込みのtext pluginを`.textlintrc.json`のpluginより先に並べるためです。
- scoped package(`@scope/textlint-rule-*`)のplugin名は、npm名からscopeを除いたものです(例: `@textlint-ja/textlint-rule-no-filler`は`plugins.textlint-rule-no-filler`)。`.textlintrc.json`ではscopeが必要で、`"rules": { "@textlint-ja/no-filler": true }`のようにscope付きのルール名で指定します。

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
| [`slopless`](https://github.com/berelevant-ai/slopless) | 英語の文章からAI生成らしい表現(AI slop)を検出するプリセット(`.textlintrc`では`"preset-slopless": true`で有効にする。`slopless` CLIは含まない) |
| [`textlint-filter-rule-allowlist`](https://github.com/textlint/textlint-filter-rule-allowlist) | 許可リストに書いた語句やパターンに対するエラーを無視するfilter rule |
| [`textlint-filter-rule-comments`](https://github.com/textlint/textlint-filter-rule-comments) | `<!-- textlint-disable -->`と`<!-- textlint-enable -->`のコメントで囲んだ範囲のエラーを無視するfilter rule |
| [`textlint-filter-rule-ja-named-entities`](https://github.com/textlint-ja/textlint-filter-rule-ja-named-entities) | 日本語の固有表現に対するエラーを無視するfilter rule(同梱の辞書はCC BY-SA 3.0) |
| [`textlint-filter-rule-node-types`](https://github.com/textlint/textlint-filter-rule-node-types) | 指定した種類のノード内のエラーを無視するfilter rule |
| [`textlint-filter-rule-urls`](https://github.com/textlint-rule/textlint-filter-rule-urls) | URL上のエラーを無視するfilter rule |
| [`textlint-plugin-asciidoc-loose`](https://github.com/azu/textlint-plugin-asciidoc-loose) | AsciiDocの文書をtextlintで簡易的に扱えるようにする(段落のみ。上流ではdeprecated) |
| [`textlint-plugin-asciidoctor`](https://github.com/seikichi/textlint-plugin-asciidoctor) | asciidoctor.jsでAsciiDocの文書をtextlintで扱えるようにする |
| [`textlint-plugin-html`](https://github.com/textlint/textlint-plugin-html) | HTMLの文書をtextlintで扱えるようにする |
| [`textlint-plugin-jsx`](https://github.com/hata6502/textlint-plugin-jsx) | JSX / TSXのファイルをtextlintで扱えるようにする |
| [`textlint-plugin-latex2e`](https://github.com/textlint/textlint-plugin-latex2e) | LaTeX2εの文書をtextlintで扱えるようにする |
| [`textlint-plugin-org`](https://github.com/kijimaD/textlint-plugin-org) | Org modeの文書をtextlintで扱えるようにする |
| [`textlint-plugin-review`](https://github.com/orangain/textlint-plugin-review) | Re:VIEWの文書をtextlintで扱えるようにする |
| [`textlint-plugin-rst`](https://github.com/jimo1001/textlint-plugin-rst) | reStructuredTextの文書をtextlintで扱えるようにする |
| [`textlint-plugin-satsuki`](https://github.com/7pairs/textlint-plugin-satsuki) | `.txt`のさつき記法のブロックとインラインタグをtextlintの指摘対象から外す(コマンドラインで`--plugin satsuki`の指定が必要) |
| [`textlint-rule-a3rt-proofreading`](https://github.com/sters/textlint-rule-a3rt-proofreading) | A3RTのProofreading APIで日本語を校正する(APIのホストが名前解決できないため、実用上は動かない) |
| [`textlint-rule-abbr-within-parentheses`](https://github.com/azu/textlint-rule-abbr-within-parentheses) | 略語を括弧内に書いているかを確認する |
| [`textlint-rule-alex`](https://github.com/textlint-rule/textlint-rule-alex) | alexで配慮を欠く英語表現を検出する |
| [`textlint-rule-alive-link`](https://github.com/fengma1992/textlint-rule-alive-link) | リンク切れを検出する |
| [`textlint-rule-allowed-uris`](https://github.com/lumirlumir/npm-textlint-rule-allowed-uris) | リンクや画像のURIを許可したパターンに制限する |
| [`textlint-rule-apostrophe`](https://github.com/sapegin/textlint-rule-apostrophe) | アポストロフィの使い方を確認・修正する(`'`を`’`に) |
| [`textlint-rule-arabic-diacritics`](https://github.com/aborazmeh/textlint-rule-arabic-diacritics) | アラビア語の発音記号(ダイアクリティカルマーク)の使い方を検査する |
| [`textlint-rule-arabic-letter-forms`](https://github.com/aborazmeh/textlint-rule-arabic-letter-forms) | アラビア文字の表示形(独立形・頭字形・中字形・尾字形)を検出する |
| [`textlint-rule-aws-service-name`](https://github.com/bun913/textlint-rule-aws-service-name) | AWSのサービス名の表記を確認する |
| [`textlint-rule-azure-product-name`](https://github.com/dora56/textlint-rule-azure-product-name) | Azureの製品名の表記を検査する |
| [`textlint-rule-chunk-size`](https://github.com/hoffination/textlint-rule-chunk-size) | 区切り文字列(既定は`page: `)の間の文字数を制限する |
| [`textlint-rule-common-misspellings`](https://github.com/io-monad/textlint-rule-common-misspellings) | 英語のよくある綴り間違いを検出する |
| [`textlint-rule-date-weekday-mismatch`](https://github.com/textlint-rule/textlint-rule-date-weekday-mismatch) | 日付と曜日の不一致を検出する |
| [`textlint-rule-diacritics`](https://github.com/sapegin/textlint-rule-diacritics) | ダイアクリティカルマークの付け忘れを検出する |
| [`textlint-rule-doubled-spaces`](https://github.com/iwamatsu0430/textlint-rule-doubled-spaces) | 文中の連続したスペースを検出する |
| [`textlint-rule-editorconfig`](https://github.com/arrowrowe/textlint-rule-editorconfig) | プロジェクトの`.editorconfig`に沿っているかを確認する |
| [`textlint-rule-en-capitalization`](https://github.com/textlint-rule/textlint-rule-en-capitalization) | 英語の大文字・小文字の使い方を確認する |
| [`textlint-rule-en-max-word-count`](https://github.com/textlint-rule/textlint-rule-en-max-word-count) | 英語の1文の単語数を制限する |
| [`textlint-rule-en-spell`](https://github.com/hata6502/textlint-rule-en-spell) | 同梱の辞書で英語の綴りを確認する |
| [`textlint-rule-first-sentence-length`](https://github.com/textlint-rule/textlint-rule-first-sentence-length) | セクションの最初の文の長さを制限する |
| [`textlint-rule-footnote-order`](https://github.com/textlint-rule/textlint-rule-footnote-order) | 脚注の識別子(`[^1]`)が出現順の連番になっているかを確認する(textlint 12以降は脚注が`FootnoteReference`になったため、現行のtextlintでは脚注を検出しない) |
| [`textlint-rule-gc-product-name`](https://github.com/danishi/textlint-rule-gc-product-name) | Google Cloudの製品名の表記を検査する |
| [`textlint-rule-general-novel-style-ja`](https://github.com/io-monad/textlint-rule-general-novel-style-ja) | 日本語の小説の一般的な作法に従っているかを確認する |
| [`textlint-rule-ginger`](https://github.com/textlint-rule/textlint-rule-ginger) | Gingerの校正APIで英文法を確認する(APIが終了しており訂正が返らないため、実用上は動かない) |
| [`textlint-rule-header-levels`](https://github.com/aborazmeh/textlint-rule-header-levels) | 見出しレベルを設定した範囲に制限する(既定の1〜6のままでは何も報告しない) |
| [`textlint-rule-incremental-headers`](https://github.com/matsu-chara/textlint-rule-incremental-headers) | 見出しのレベルが1つずつ深くなっているかを確認する |
| [`textlint-rule-ja-allowed-kanji`](https://github.com/matori/textlint-rule-ja-allowed-kanji) | 許可した漢字だけを使っているかを確認する(既定は常用漢字のみ) |
| [`textlint-rule-ja-hiragana-fukushi`](https://github.com/lostandfound/textlint-rule-ja-hiragana-fukushi) | ひらがなで書いたほうが読みやすい副詞を検出する |
| [`textlint-rule-ja-hiragana-hojodoushi`](https://github.com/lostandfound/textlint-rule-ja-hiragana-hojodoushi) | ひらがなで書いたほうが読みやすい補助動詞を検出する |
| [`textlint-rule-ja-hiragana-keishikimeishi`](https://github.com/lostandfound/textlint-rule-ja-hiragana-keishikimeishi) | ひらがなで書いたほうが読みやすい形式名詞を検出する |
| [`textlint-rule-ja-hiraku`](https://github.com/akiomik/textlint-rule-ja-hiraku) | ひらがなに「ひらく」ほうが読みやすい漢字表記を検出する |
| [`textlint-rule-ja-joyo-or-jinmeiyo-kanji`](https://github.com/textlint-ja/textlint-rule-ja-joyo-or-jinmeiyo-kanji) | 常用漢字でも人名用漢字でもない漢字を検出する |
| [`textlint-rule-ja-kyoiku-kanji`](https://github.com/textlint-ja/textlint-rule-ja-kyoiku-kanji) | 教育漢字ではない漢字を検出する |
| [`textlint-rule-ja-no-abusage`](https://github.com/textlint-ja/textlint-rule-ja-no-abusage) | よくある日本語の誤用を検出する |
| [`textlint-rule-ja-no-inappropriate-words`](https://github.com/textlint-ja/textlint-rule-ja-no-inappropriate-words) | 不適切表現を検出する |
| [`textlint-rule-ja-no-mixed-period`](https://github.com/textlint-ja/textlint-rule-ja-no-mixed-period) | 文末の句点(。)の抜けや不統一を検出する |
| [`textlint-rule-ja-no-orthographic-variants`](https://github.com/textlint-ja/textlint-rule-ja-no-orthographic-variants) | 表記ゆれを検出する |
| [`textlint-rule-ja-no-redundant-expression`](https://github.com/textlint-ja/textlint-rule-ja-no-redundant-expression) | 冗長な表現を禁止する |
| [`textlint-rule-ja-no-weak-phrase`](https://github.com/textlint-ja/textlint-rule-ja-no-weak-phrase) | 「〜と思います」などの弱い表現を禁止する |
| [`textlint-rule-ja-overlooked-typo`](https://github.com/GunseiKPaseri/textlint-rule-ja-overlooked-typo) | 漢字の「二」とカタカナの「ニ」の取り違えなど、見逃しがちなタイプミスを検出する |
| [`textlint-rule-ja-simple-user-dictionary`](https://github.com/hata6502/textlint-rule-ja-simple-user-dictionary) | シンプルなユーザー辞書に登録した語を検出する(`dictionary`を設定しないと何も報告しない) |
| [`textlint-rule-ja-unnatural-alphabet`](https://github.com/textlint-ja/textlint-rule-ja-unnatural-alphabet) | IMEの入力ミスによる不自然なアルファベットを検出する |
| [`textlint-rule-ja-yahoo-kousei`](https://github.com/KeitaMoromizato/textlint-rule-ja-yahoo-kousei) | Yahoo! JAPANの校正支援API(V1)で日本語を校正する(APIのエンドポイントが現存しないため、実用上は動かない) |
| [`textlint-rule-jis-charset`](https://github.com/lostandfound/textlint-rule-jis-charset) | JIS X 0213:2004の範囲外の文字を検出する |
| [`textlint-rule-joyo-kanji`](https://github.com/kongou-ae/textlint-rule-joyo-kanji) | 常用漢字ではない漢字を検出する |
| [`textlint-rule-kmu-termcheck`](https://github.com/kmuto/textlint-rule-kmu-termcheck) | サービス名や製品名の綴り間違いを検出する |
| [`textlint-rule-languagetool`](https://github.com/UFOMelkor/textlint-rule-languagetool) | LanguageTool(nixpkgsのもの、ネットワーク不要)で文章を確認する。上流の制限: 1回の実行でLanguageToolに送るテキストが2つ以上あるとハングする(見出しと段落がある、段落やリスト項目が2つ以上ある、段落にインライン装飾がある場合など。複数ファイルに分かれていても同じ。[node-languagetool#4](https://github.com/schreiben/node-languagetool/issues/4))。最後のファイルにテキストがないと、結果を表示したあと終了しない。一致の多い長い段落では応答が1チャンクに収まらず、JSONの`SyntaxError`で落ちる。UTF-8 localeがない環境では応答の非ASCII文字が化けうる |
| [`textlint-rule-max-appearence-count-of-words`](https://github.com/KeitaMoromizato/textlint-rule-max-appearence-count-of-words) | 段落内で同じ単語が出現する回数を制限する |
| [`textlint-rule-max-comma`](https://github.com/textlint-rule/textlint-rule-max-comma) | 1文中のカンマ(`,`)の数を制限する |
| [`textlint-rule-max-doc-width`](https://github.com/0Delta/textlint-rule-max-doc-width) | 1行の表示幅を制限する |
| [`textlint-rule-max-kanji-continuous-len`](https://github.com/textlint-ja/textlint-rule-max-kanji-continuous-len) | 漢字が連続する長さを制限する |
| [`textlint-rule-max-length-of-title`](https://github.com/KeitaMoromizato/textlint-rule-max-length-of-title) | タイトル(見出し)の長さを制限する |
| [`textlint-rule-max-number-of-lines`](https://github.com/textlint-rule/textlint-rule-max-number-of-lines) | 文書の行数を制限する |
| [`textlint-rule-max-ten`](https://github.com/textlint-ja/textlint-rule-max-ten) | 1文中の読点(、)の数を制限する |
| [`textlint-rule-neighbor`](https://github.com/a11yfred/neighbor/tree/main/packages/textlint-rule-neighbor) | アクセシビリティや包摂性を損なう英語表現を検出する |
| [`textlint-rule-ng-word`](https://github.com/KeitaMoromizato/textlint-rule-ng-word) | 設定したNGワードを検出する |
| [`textlint-rule-no-bold-paragraph`](https://github.com/aborazmeh/textlint-rule-no-bold-paragraph) | 全体が太字の段落を検出する |
| [`textlint-rule-no-curly-quotes`](https://github.com/aborazmeh/textlint-rule-no-curly-quotes) | 曲線の引用符(“ ” ‘ ’)を禁止する |
| [`textlint-rule-no-dead-link`](https://github.com/textlint-rule/textlint-rule-no-dead-link) | リンク切れを検出する |
| [`textlint-rule-no-double-negative-ja`](https://github.com/textlint-ja/textlint-rule-no-double-negative-ja) | 二重否定を検出する |
| [`textlint-rule-no-doubled-conjunction`](https://github.com/textlint-ja/textlint-rule-no-doubled-conjunction) | 同じ接続詞が連続して使われているのを検出する |
| [`textlint-rule-no-doubled-conjunctive-particle-ga`](https://github.com/textlint-ja/textlint-rule-no-doubled-conjunctive-particle-ga) | 一文に逆接の接続助詞「が」が複数回出てくるのを検出する |
| [`textlint-rule-no-doubled-joshi`](https://github.com/textlint-ja/textlint-rule-no-doubled-joshi) | 1文中で同じ助詞が重複しているのを検出する |
| [`textlint-rule-no-dropping-the-ra`](https://github.com/textlint-ja/textlint-rule-no-dropping-the-ra) | ら抜き言葉を検出する |
| [`textlint-rule-no-duplicate-abbr`](https://github.com/textlint-rule/textlint-rule-no-duplicate-abbr) | 「NPO organization」のように略語の末尾語と重複する語を検出する |
| [`textlint-rule-no-empty-element`](https://github.com/AhmedElwerdany/textlint-rule-no-empty-element) | 引用やコードブロックなど、中身が空のMarkdown要素を検出する |
| [`textlint-rule-no-empty-section`](https://github.com/azu/textlint-rule-no-empty-section) | 本文のないセクションを禁止する |
| [`textlint-rule-no-exclamation-question-mark`](https://github.com/textlint-rule/textlint-rule-no-exclamation-question-mark) | 感嘆符と疑問符の使用を禁止する |
| [`textlint-rule-no-filler`](https://github.com/textlint-ja/textlint-rule-no-filler) | 「えーと」などのフィラー(つなぎ表現)を禁止する |
| [`textlint-rule-no-hankaku-kana`](https://github.com/textlint-ja/textlint-rule-no-hankaku-kana) | 半角カタカナの使用を禁止する |
| [`textlint-rule-no-hoso-kinshi-yogo`](https://github.com/hata6502/textlint-rule-no-hoso-kinshi-yogo) | 放送禁止用語を検出する(実行時に辞書をmonoroch.netからダウンロードするため、ネットワーク接続が必要) |
| [`textlint-rule-no-insert-dropping-sa`](https://github.com/textlint-ja/textlint-rule-no-insert-dropping-sa) | サ抜き・サ入れ表現の誤用を検出する |
| [`textlint-rule-no-invalid-control-character`](https://github.com/textlint-rule/textlint-rule-no-invalid-control-character) | 不正な制御文字を禁止する |
| [`textlint-rule-no-isolated-waw`](https://github.com/aborazmeh/textlint-rule-no-isolated-waw) | アラビア語の接続詞wawが次の語から離れている箇所を検出する |
| [`textlint-rule-no-kasheeda`](https://github.com/aborazmeh/textlint-rule-no-kasheeda) | アラビア語やペルシア語のカシーダ(U+0640)を禁止する |
| [`textlint-rule-no-mix-dearu-desumasu`](https://github.com/textlint-ja/textlint-rule-no-mix-dearu-desumasu) | 「である」調と「ですます」調の混在を禁止する |
| [`textlint-rule-no-mixed-punctuations`](https://github.com/aborazmeh/textlint-rule-no-mixed-punctuations) | LTRとRTLの句読点の混在を禁止する |
| [`textlint-rule-no-mixed-zenkaku-and-hankaku-alphabet`](https://github.com/textlint-ja/textlint-rule-no-mixed-zenkaku-and-hankaku-alphabet) | 全角と半角のアルファベットの混在を検出する |
| [`textlint-rule-no-nfd`](https://github.com/textlint-ja/textlint-rule-no-nfd) | 濁点などが分解されたNFD文字を禁止する |
| [`textlint-rule-no-start-duplicated-conjunction`](https://github.com/textlint-rule/textlint-rule-no-start-duplicated-conjunction) | 同じ接続詞で始まる文の繰り返しを検出する |
| [`textlint-rule-no-surrogate-pair`](https://github.com/lostandfound/textlint-rule-no-surrogate-pair) | サロゲートペアの文字を検出する |
| [`textlint-rule-no-synonyms`](https://github.com/textlint-ja/textlint-rule-no-synonyms) | 同義語の表記ゆれを検出する |
| [`textlint-rule-no-todo`](https://github.com/textlint-rule/textlint-rule-no-todo) | 残っているTODOを検出する |
| [`textlint-rule-no-unmatched-pair`](https://github.com/textlint-rule/textlint-rule-no-unmatched-pair) | 対応の取れていない括弧や引用符を検出する |
| [`textlint-rule-no-zero-width-spaces`](https://github.com/textlint-rule/textlint-rule-no-zero-width-spaces) | ゼロ幅スペースを禁止する |
| [`textlint-rule-numeral-systems`](https://github.com/aborazmeh/textlint-rule-numeral-systems) | アラビア数字・アラビア・インド数字・ペルシア数字の表記を統一する |
| [`textlint-rule-period-in-header`](https://github.com/ohakutsu/textlint-rule-period-in-header) | 見出し末尾の句点の有無を確認する |
| [`textlint-rule-period-in-list-item`](https://github.com/textlint-rule/textlint-rule-period-in-list-item) | リスト項目の末尾のピリオドの有無を揃える |
| [`textlint-rule-prefer-tari-tari`](https://github.com/textlint-ja/textlint-rule-prefer-tari-tari) | 「〜たり〜たりする」表現を確認する |
| [`textlint-rule-preset-ai-words-ja`](https://github.com/p1ass/textlint-rule-preset-ai-words-ja) | AIが書いた日本語に多い表現を検出するプリセット |
| [`textlint-rule-preset-ja-engineering-paper`](https://github.com/kn1cht/textlint-rule-preset-ja-engineering-paper) | 工学系の日本語論文向けのルールプリセット |
| [`textlint-rule-preset-ja-spacing`](https://github.com/textlint-ja/textlint-rule-preset-ja-spacing) | 日本語のスペース周りのスタイルを扱うプリセット |
| [`textlint-rule-preset-ja-technical-writing`](https://github.com/textlint-ja/textlint-rule-preset-ja-technical-writing) | 技術文書向けのルールプリセット |
| [`textlint-rule-preset-japanese`](https://github.com/textlint-ja/textlint-rule-preset-japanese) | 日本語向けのルールプリセット |
| [`textlint-rule-preset-jtf-style`](https://github.com/textlint-ja/textlint-rule-preset-JTF-style) | JTF日本語標準スタイルガイド(翻訳用)のルールプリセット |
| [`textlint-rule-prh`](https://github.com/textlint-rule/textlint-rule-prh) | prhの辞書で表記ゆれを検出する |
| [`textlint-rule-report-node-types`](https://github.com/textlint/textlint-rule-report-node-types) | 指定した種類のノードを報告する(デバッグ用) |
| [`textlint-rule-require-header-id`](https://github.com/textlint-rule/textlint-rule-require-header-id) | 各見出しに`{#id}`を要求する |
| [`textlint-rule-rousseau`](https://github.com/textlint-rule/textlint-rule-rousseau) | rousseauで英語の読みやすさを確認する |
| [`textlint-rule-sentence-length`](https://github.com/textlint-rule/textlint-rule-sentence-length) | 一文の長さを制限する |
| [`textlint-rule-sjsj`](https://github.com/azu/textlint-rule-sjsj) | JavaScript用語(SJSJ)の綴りを確認する |
| [`textlint-rule-spellchecker`](https://github.com/textlint-rule/textlint-rule-spellchecker) | ネイティブのスペルチェッカーで綴りを確認する(Linuxでは同梱のHunspell、macOSではNSSpellChecker)。Linuxでは`$LANG`の言語の辞書を探し、同梱は`en_US`だけなので、`LANG`が`en_US.*`(または未設定)でないと何も報告しない |
| [`textlint-rule-spelling`](https://github.com/tani/textlint-rule-spelling) | nspellで綴りを確認する(`dictionary-en`を同梱。使えるのは`language: "en"`のみ) |
| [`textlint-rule-stop-words`](https://github.com/sapegin/textlint-rule-stop-words) | 冗長な語や決まり文句を検出する |
| [`textlint-rule-terminology`](https://github.com/sapegin/textlint-rule-terminology) | 技術用語の表記を揃える |
| [`textlint-rule-terminology-zh`](https://www.npmjs.com/package/textlint-rule-terminology-zh) | 中国語と英語の用語の表記を揃える |
| [`textlint-rule-ukraine`](https://github.com/damian-buho/textlint-rule-ukraine) | ウクライナの地名・人名のロシア語由来の綴りを検出する |
| [`textlint-rule-unexpanded-acronym`](https://github.com/textlint-rule/textlint-rule-unexpanded-acronym) | 展開されていない頭字語を検出する |
| [`textlint-rule-use-si-units`](https://github.com/kn1cht/textlint-rule-use-si-units) | SI単位系以外の単位の使用を禁止する |
| [`textlint-rule-write-good`](https://github.com/textlint-rule/textlint-rule-write-good) | write-goodで英語の文体を確認する |
| [`textlint-rule-zh-half-and-full-width-bracket`](https://github.com/ylc395/textlint-rule-zh-half-and-full-width-bracket) | 中国語の文章での全角・半角括弧の使い分けを検査する |

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
