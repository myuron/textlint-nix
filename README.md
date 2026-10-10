# textlint-nix

[日本語](./README-jp.md)

A flake for managing [textlint](https://github.com/textlint/textlint) and its plugins in one place with Nix.

Add textlint-nix to the inputs of your project's `flake.nix` and enable the plugins you want with `plugins.<name>.enable = true;` to get a `textlint` command with those plugins built in. No `package.json` or `node_modules` is needed.

In this document, "plugin" refers to any package that extends textlint, including rules (`textlint-rule-*`), filter rules (`textlint-filter-rule-*`), and plugins (`textlint-plugin-*`).

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

Presets, `textlint-filter-rule-*` packages, and `textlint-plugin-*` packages are specified differently.

- For `textlint-rule-preset-*`, keep the `preset-` prefix, as in `"rules": { "preset-ja-technical-writing": true }`.
- For `textlint-plugin-*`, list the name without the `textlint-plugin-` prefix under `plugins`, as in `"plugins": ["latex2e"]`.
- For `textlint-filter-rule-*`, put the name without the `textlint-filter-rule-` prefix under `filters`, as in `"filters": { "comments": true }`. A filter rule reports nothing on its own: it suppresses errors reported by the rules under `rules`.
- `textlint-rule-prh` reports nothing unless you point `rulePaths` at a dictionary.
- `textlint-plugin-satsuki` only takes effect when passed on the command line, as in `textlint --plugin satsuki file.txt`. Listing it under `plugins` in `.textlintrc.json` has no effect, because textlint puts its built-in text plugin, which also handles `.txt`, ahead of the plugins from `.textlintrc.json`.
- For scoped packages (`@scope/textlint-rule-*`), the plugin name is the npm name without the scope, as in `plugins.textlint-rule-no-filler` for `@textlint-ja/textlint-rule-no-filler`. In `.textlintrc.json`, the scope is still required: use the scoped rule name, as in `"rules": { "@textlint-ja/no-filler": true }`.

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
| [`slopless`](https://github.com/berelevant-ai/slopless) | Preset that catches AI-slop patterns in English prose (enable it with `"preset-slopless": true` in `.textlintrc`; the `slopless` CLI is not installed) |
| [`textlint-filter-rule-allowlist`](https://github.com/textlint/textlint-filter-rule-allowlist) | Filter rule that ignores errors on allowlisted words and patterns |
| [`textlint-filter-rule-comments`](https://github.com/textlint/textlint-filter-rule-comments) | Filter rule that ignores errors between `<!-- textlint-disable -->` and `<!-- textlint-enable -->` comments |
| [`textlint-filter-rule-ja-named-entities`](https://github.com/textlint-ja/textlint-filter-rule-ja-named-entities) | Filter rule that ignores errors on Japanese named entities (the bundled dictionary is CC BY-SA 3.0) |
| [`textlint-filter-rule-node-types`](https://github.com/textlint/textlint-filter-rule-node-types) | Filter rule that ignores errors in nodes of the configured types |
| [`textlint-filter-rule-urls`](https://github.com/textlint-rule/textlint-filter-rule-urls) | Filter rule that ignores errors at URLs |
| [`textlint-plugin-asciidoc-loose`](https://github.com/azu/textlint-plugin-asciidoc-loose) | Lets textlint handle AsciiDoc documents loosely, paragraphs only (deprecated upstream) |
| [`textlint-plugin-asciidoctor`](https://github.com/seikichi/textlint-plugin-asciidoctor) | Lets textlint handle AsciiDoc documents with asciidoctor.js |
| [`textlint-plugin-html`](https://github.com/textlint/textlint-plugin-html) | Lets textlint handle HTML documents |
| [`textlint-plugin-jsx`](https://github.com/hata6502/textlint-plugin-jsx) | Lets textlint handle JSX and TSX files |
| [`textlint-plugin-latex2e`](https://github.com/textlint/textlint-plugin-latex2e) | Lets textlint handle LaTeX2ε documents |
| [`textlint-plugin-org`](https://github.com/kijimaD/textlint-plugin-org) | Lets textlint handle Org mode documents |
| [`textlint-plugin-review`](https://github.com/orangain/textlint-plugin-review) | Lets textlint handle Re:VIEW documents |
| [`textlint-plugin-rst`](https://github.com/jimo1001/textlint-plugin-rst) | Lets textlint handle reStructuredText documents |
| [`textlint-plugin-satsuki`](https://github.com/7pairs/textlint-plugin-satsuki) | Makes textlint ignore blocks and inline tags of Satsuki notation in `.txt` files (needs `--plugin satsuki` on the command line) |
| [`textlint-rule-a3rt-proofreading`](https://github.com/sters/textlint-rule-a3rt-proofreading) | Proofreads Japanese with the A3RT Proofreading API (does not work in practice: the API host no longer resolves) |
| [`textlint-rule-abbr-within-parentheses`](https://github.com/azu/textlint-rule-abbr-within-parentheses) | Checks that abbreviations are written within parentheses |
| [`textlint-rule-alex`](https://github.com/textlint-rule/textlint-rule-alex) | Detects insensitive, inconsiderate English writing with alex |
| [`textlint-rule-alive-link`](https://github.com/fengma1992/textlint-rule-alive-link) | Checks that links are alive |
| [`textlint-rule-allowed-uris`](https://github.com/lumirlumir/npm-textlint-rule-allowed-uris) | Restricts the URIs of links and images to allowed patterns |
| [`textlint-rule-apostrophe`](https://github.com/sapegin/textlint-rule-apostrophe) | Checks and fixes apostrophes (`'` to `’`) |
| [`textlint-rule-arabic-diacritics`](https://github.com/aborazmeh/textlint-rule-arabic-diacritics) | Checks the usage of Arabic diacritics |
| [`textlint-rule-arabic-letter-forms`](https://github.com/aborazmeh/textlint-rule-arabic-letter-forms) | Detects Arabic presentation forms of letters (isolated, initial, medial, final) |
| [`textlint-rule-aws-service-name`](https://github.com/bun913/textlint-rule-aws-service-name) | Checks the names of AWS services |
| [`textlint-rule-azure-product-name`](https://github.com/dora56/textlint-rule-azure-product-name) | Checks the spelling of Azure product names |
| [`textlint-rule-chunk-size`](https://github.com/hoffination/textlint-rule-chunk-size) | Limits the number of characters between delimiters (`page: ` by default) |
| [`textlint-rule-common-misspellings`](https://github.com/io-monad/textlint-rule-common-misspellings) | Detects common English misspellings |
| [`textlint-rule-date-weekday-mismatch`](https://github.com/textlint-rule/textlint-rule-date-weekday-mismatch) | Detects mismatches between a date and its weekday |
| [`textlint-rule-diacritics`](https://github.com/sapegin/textlint-rule-diacritics) | Detects missing diacritics |
| [`textlint-rule-doubled-spaces`](https://github.com/iwamatsu0430/textlint-rule-doubled-spaces) | Detects doubled spaces in a sentence |
| [`textlint-rule-editorconfig`](https://github.com/arrowrowe/textlint-rule-editorconfig) | Checks text against the project's `.editorconfig` |
| [`textlint-rule-en-capitalization`](https://github.com/textlint-rule/textlint-rule-en-capitalization) | Checks capitalization in English text |
| [`textlint-rule-en-max-word-count`](https://github.com/textlint-rule/textlint-rule-en-max-word-count) | Limits the number of words in an English sentence |
| [`textlint-rule-en-spell`](https://github.com/hata6502/textlint-rule-en-spell) | Checks English spelling with a bundled dictionary |
| [`textlint-rule-first-sentence-length`](https://github.com/textlint-rule/textlint-rule-first-sentence-length) | Limits the length of the first sentence of a section |
| [`textlint-rule-footnote-order`](https://github.com/textlint-rule/textlint-rule-footnote-order) | Checks that footnote identifiers (`[^1]`) are numbered in order of appearance (detects nothing with current textlint: since textlint 12 footnotes are parsed as `FootnoteReference` nodes, which the rule does not handle) |
| [`textlint-rule-gc-product-name`](https://github.com/danishi/textlint-rule-gc-product-name) | Checks the spelling of Google Cloud product names |
| [`textlint-rule-general-novel-style-ja`](https://github.com/io-monad/textlint-rule-general-novel-style-ja) | Checks the general style conventions of Japanese novels |
| [`textlint-rule-ginger`](https://github.com/textlint-rule/textlint-rule-ginger) | Checks English grammar with the Ginger proofreading API (does not work in practice: the API has been retired and returns no corrections) |
| [`textlint-rule-header-levels`](https://github.com/aborazmeh/textlint-rule-header-levels) | Restricts header levels to the configured range (reports nothing with the default range of 1 to 6) |
| [`textlint-rule-incremental-headers`](https://github.com/matsu-chara/textlint-rule-incremental-headers) | Checks that header levels increase one at a time |
| [`textlint-rule-ja-allowed-kanji`](https://github.com/matori/textlint-rule-ja-allowed-kanji) | Allows only the specified sets of kanji (jōyō kanji by default) |
| [`textlint-rule-ja-hiragana-fukushi`](https://github.com/lostandfound/textlint-rule-ja-hiragana-fukushi) | Prefers hiragana for adverbs (副詞) that are easier to read in hiragana |
| [`textlint-rule-ja-hiragana-hojodoushi`](https://github.com/lostandfound/textlint-rule-ja-hiragana-hojodoushi) | Prefers hiragana for auxiliary verbs (補助動詞) |
| [`textlint-rule-ja-hiragana-keishikimeishi`](https://github.com/lostandfound/textlint-rule-ja-hiragana-keishikimeishi) | Prefers hiragana for formal nouns (形式名詞) |
| [`textlint-rule-ja-hiraku`](https://github.com/akiomik/textlint-rule-ja-hiraku) | Detects kanji that read better when written in hiragana |
| [`textlint-rule-ja-joyo-or-jinmeiyo-kanji`](https://github.com/textlint-ja/textlint-rule-ja-joyo-or-jinmeiyo-kanji) | Detects kanji that are neither jōyō nor jinmeiyō kanji |
| [`textlint-rule-ja-kyoiku-kanji`](https://github.com/textlint-ja/textlint-rule-ja-kyoiku-kanji) | Detects kanji outside the kyōiku kanji |
| [`textlint-rule-ja-no-abusage`](https://github.com/textlint-ja/textlint-rule-ja-no-abusage) | Detects common misuse of Japanese words |
| [`textlint-rule-ja-no-inappropriate-words`](https://github.com/textlint-ja/textlint-rule-ja-no-inappropriate-words) | Detects inappropriate Japanese words |
| [`textlint-rule-ja-no-mixed-period`](https://github.com/textlint-ja/textlint-rule-ja-no-mixed-period) | Checks for missing or inconsistent periods (。) at the end of sentences |
| [`textlint-rule-ja-no-orthographic-variants`](https://github.com/textlint-ja/textlint-rule-ja-no-orthographic-variants) | Detects orthographic variants (表記ゆれ) in Japanese |
| [`textlint-rule-ja-no-redundant-expression`](https://github.com/textlint-ja/textlint-rule-ja-no-redundant-expression) | Disallows redundant expressions in Japanese |
| [`textlint-rule-ja-no-weak-phrase`](https://github.com/textlint-ja/textlint-rule-ja-no-weak-phrase) | Disallows weak phrases such as 「〜と思います」 |
| [`textlint-rule-ja-overlooked-typo`](https://github.com/GunseiKPaseri/textlint-rule-ja-overlooked-typo) | Detects easily overlooked typos such as the kanji 二 in place of the katakana ニ |
| [`textlint-rule-ja-simple-user-dictionary`](https://github.com/hata6502/textlint-rule-ja-simple-user-dictionary) | Detects the words listed in a simple user dictionary (reports nothing without a `dictionary`) |
| [`textlint-rule-ja-unnatural-alphabet`](https://github.com/textlint-ja/textlint-rule-ja-unnatural-alphabet) | Detects unnatural alphabets caused by IME typos |
| [`textlint-rule-ja-yahoo-kousei`](https://github.com/KeitaMoromizato/textlint-rule-ja-yahoo-kousei) | Proofreads Japanese with the Yahoo! JAPAN proofreading API V1 (does not work in practice: the API endpoint no longer exists) |
| [`textlint-rule-jis-charset`](https://github.com/lostandfound/textlint-rule-jis-charset) | Detects characters outside JIS X 0213:2004 |
| [`textlint-rule-joyo-kanji`](https://github.com/kongou-ae/textlint-rule-joyo-kanji) | Detects kanji outside the jōyō kanji |
| [`textlint-rule-kmu-termcheck`](https://github.com/kmuto/textlint-rule-kmu-termcheck) | Detects misspelled service and product names |
| [`textlint-rule-languagetool`](https://github.com/UFOMelkor/textlint-rule-languagetool) | Checks text with LanguageTool (from nixpkgs, no network access). Upstream limitations: textlint hangs when a single run sends more than one text to LanguageTool, for example a heading and a paragraph, more than one paragraph or list item, or a paragraph with inline markup, even when they are in different files ([node-languagetool#4](https://github.com/schreiben/node-languagetool/issues/4)); it does not exit after printing the results when the last file has no text; a long paragraph with many matches fails with a JSON `SyntaxError`, because the response does not fit in one chunk; without a UTF-8 locale, non-ASCII characters in the responses may be garbled |
| [`textlint-rule-max-appearence-count-of-words`](https://github.com/KeitaMoromizato/textlint-rule-max-appearence-count-of-words) | Limits how many times a word appears in a paragraph |
| [`textlint-rule-max-comma`](https://github.com/textlint-rule/textlint-rule-max-comma) | Limits the number of commas (`,`) in a sentence |
| [`textlint-rule-max-doc-width`](https://github.com/0Delta/textlint-rule-max-doc-width) | Limits the display width of each line |
| [`textlint-rule-max-kanji-continuous-len`](https://github.com/textlint-ja/textlint-rule-max-kanji-continuous-len) | Limits the length of consecutive kanji |
| [`textlint-rule-max-length-of-title`](https://github.com/KeitaMoromizato/textlint-rule-max-length-of-title) | Limits the length of titles (headers) |
| [`textlint-rule-max-number-of-lines`](https://github.com/textlint-rule/textlint-rule-max-number-of-lines) | Limits the number of lines in a document |
| [`textlint-rule-max-ten`](https://github.com/textlint-ja/textlint-rule-max-ten) | Limits the number of ten (、) in a sentence |
| [`textlint-rule-neighbor`](https://github.com/a11yfred/neighbor/tree/main/packages/textlint-rule-neighbor) | Detects inaccessible and non-inclusive English wording |
| [`textlint-rule-ng-word`](https://github.com/KeitaMoromizato/textlint-rule-ng-word) | Detects the configured NG words |
| [`textlint-rule-no-bold-paragraph`](https://github.com/aborazmeh/textlint-rule-no-bold-paragraph) | Detects paragraphs that are entirely bold |
| [`textlint-rule-no-curly-quotes`](https://github.com/aborazmeh/textlint-rule-no-curly-quotes) | Disallows curly quotation marks |
| [`textlint-rule-no-dead-link`](https://github.com/textlint-rule/textlint-rule-no-dead-link) | Detects dead links |
| [`textlint-rule-no-double-negative-ja`](https://github.com/textlint-ja/textlint-rule-no-double-negative-ja) | Detects double negatives in Japanese |
| [`textlint-rule-no-doubled-conjunction`](https://github.com/textlint-ja/textlint-rule-no-doubled-conjunction) | Detects the same conjunction used in consecutive sentences |
| [`textlint-rule-no-doubled-conjunctive-particle-ga`](https://github.com/textlint-ja/textlint-rule-no-doubled-conjunctive-particle-ga) | Detects the conjunctive particle 「が」 used more than once in a sentence |
| [`textlint-rule-no-doubled-joshi`](https://github.com/textlint-ja/textlint-rule-no-doubled-joshi) | Detects the same particle (joshi) repeated in a sentence |
| [`textlint-rule-no-dropping-the-ra`](https://github.com/textlint-ja/textlint-rule-no-dropping-the-ra) | Detects ら抜き言葉 |
| [`textlint-rule-no-duplicate-abbr`](https://github.com/textlint-rule/textlint-rule-no-duplicate-abbr) | Detects a word that duplicates the last word of an abbreviation, as in "NPO organization" |
| [`textlint-rule-no-empty-element`](https://github.com/AhmedElwerdany/textlint-rule-no-empty-element) | Detects empty Markdown elements such as quotes and code blocks |
| [`textlint-rule-no-empty-section`](https://github.com/azu/textlint-rule-no-empty-section) | Disallows sections without content |
| [`textlint-rule-no-exclamation-question-mark`](https://github.com/textlint-rule/textlint-rule-no-exclamation-question-mark) | Disallows exclamation and question marks |
| [`textlint-rule-no-filler`](https://github.com/textlint-ja/textlint-rule-no-filler) | Disallows Japanese filler words such as 「えーと」 |
| [`textlint-rule-no-hankaku-kana`](https://github.com/textlint-ja/textlint-rule-no-hankaku-kana) | Disallows half-width katakana |
| [`textlint-rule-no-hoso-kinshi-yogo`](https://github.com/hata6502/textlint-rule-no-hoso-kinshi-yogo) | Detects words unsuitable for broadcasting (downloads its dictionary from monoroch.net at run time, so it needs network access) |
| [`textlint-rule-no-insert-dropping-sa`](https://github.com/textlint-ja/textlint-rule-no-insert-dropping-sa) | Detects misuse of サ抜き / サ入れ expressions in Japanese |
| [`textlint-rule-no-invalid-control-character`](https://github.com/textlint-rule/textlint-rule-no-invalid-control-character) | Disallows invalid control characters |
| [`textlint-rule-no-isolated-waw`](https://github.com/aborazmeh/textlint-rule-no-isolated-waw) | Detects the Arabic conjunction waw written apart from the following word |
| [`textlint-rule-no-kasheeda`](https://github.com/aborazmeh/textlint-rule-no-kasheeda) | Disallows the kasheeda (U+0640) in Arabic and Farsi text |
| [`textlint-rule-no-mix-dearu-desumasu`](https://github.com/textlint-ja/textlint-rule-no-mix-dearu-desumasu) | Disallows mixing である and ですます styles |
| [`textlint-rule-no-mixed-punctuations`](https://github.com/aborazmeh/textlint-rule-no-mixed-punctuations) | Disallows mixing LTR and RTL punctuation |
| [`textlint-rule-no-mixed-zenkaku-and-hankaku-alphabet`](https://github.com/textlint-ja/textlint-rule-no-mixed-zenkaku-and-hankaku-alphabet) | Detects mixed full-width and half-width alphabets |
| [`textlint-rule-no-nfd`](https://github.com/textlint-ja/textlint-rule-no-nfd) | Disallows NFD characters such as decomposed 濁点 |
| [`textlint-rule-no-start-duplicated-conjunction`](https://github.com/textlint-rule/textlint-rule-no-start-duplicated-conjunction) | Detects consecutive sentences that start with the same conjunction |
| [`textlint-rule-no-surrogate-pair`](https://github.com/lostandfound/textlint-rule-no-surrogate-pair) | Detects surrogate pairs |
| [`textlint-rule-no-synonyms`](https://github.com/textlint-ja/textlint-rule-no-synonyms) | Detects inconsistent use of Japanese synonyms |
| [`textlint-rule-no-todo`](https://github.com/textlint-rule/textlint-rule-no-todo) | Detects leftover TODO marks |
| [`textlint-rule-no-unmatched-pair`](https://github.com/textlint-rule/textlint-rule-no-unmatched-pair) | Detects unmatched pairs of brackets and quotes |
| [`textlint-rule-no-zero-width-spaces`](https://github.com/textlint-rule/textlint-rule-no-zero-width-spaces) | Disallows zero width spaces |
| [`textlint-rule-numeral-systems`](https://github.com/aborazmeh/textlint-rule-numeral-systems) | Unifies Arabic, Arabic-Indic and Persian numerals |
| [`textlint-rule-period-in-header`](https://github.com/ohakutsu/textlint-rule-period-in-header) | Checks for a period at the end of headers |
| [`textlint-rule-period-in-list-item`](https://github.com/textlint-rule/textlint-rule-period-in-list-item) | Enforces the presence or absence of a period at the end of list items |
| [`textlint-rule-prefer-tari-tari`](https://github.com/textlint-ja/textlint-rule-prefer-tari-tari) | Checks the 「〜たり〜たりする」 expression |
| [`textlint-rule-preset-ai-words-ja`](https://github.com/p1ass/textlint-rule-preset-ai-words-ja) | Preset that detects expressions common in AI-generated Japanese |
| [`textlint-rule-preset-ja-engineering-paper`](https://github.com/kn1cht/textlint-rule-preset-ja-engineering-paper) | Rule preset for Japanese engineering papers |
| [`textlint-rule-preset-ja-spacing`](https://github.com/textlint-ja/textlint-rule-preset-ja-spacing) | Preset for spacing style in Japanese text |
| [`textlint-rule-preset-ja-technical-writing`](https://github.com/textlint-ja/textlint-rule-preset-ja-technical-writing) | Rule preset for Japanese technical writing |
| [`textlint-rule-preset-japanese`](https://github.com/textlint-ja/textlint-rule-preset-japanese) | Rule preset for Japanese text |
| [`textlint-rule-preset-jtf-style`](https://github.com/textlint-ja/textlint-rule-preset-JTF-style) | Rule preset for the JTF style guide for Japanese translation |
| [`textlint-rule-prh`](https://github.com/textlint-rule/textlint-rule-prh) | Detects inconsistent spelling with prh dictionaries |
| [`textlint-rule-report-node-types`](https://github.com/textlint/textlint-rule-report-node-types) | Reports nodes of the configured types, for debugging |
| [`textlint-rule-require-header-id`](https://github.com/textlint-rule/textlint-rule-require-header-id) | Requires `{#id}` on each header |
| [`textlint-rule-rousseau`](https://github.com/textlint-rule/textlint-rule-rousseau) | Checks English readability with rousseau |
| [`textlint-rule-sentence-length`](https://github.com/textlint-rule/textlint-rule-sentence-length) | Limits the length of a sentence |
| [`textlint-rule-sjsj`](https://github.com/azu/textlint-rule-sjsj) | Checks the spelling of JavaScript jargon (SJSJ) |
| [`textlint-rule-spellchecker`](https://github.com/textlint-rule/textlint-rule-spellchecker) | Checks spelling with a native spellchecker (on Linux the bundled Hunspell, on macOS NSSpellChecker). On Linux it looks for the dictionary of the language in `$LANG` and only `en_US` is bundled, so it reports nothing unless `LANG` is `en_US.*` or unset |
| [`textlint-rule-spelling`](https://github.com/tani/textlint-rule-spelling) | Checks spelling with nspell (bundles `dictionary-en`, so only `language: "en"` is available) |
| [`textlint-rule-stop-words`](https://github.com/sapegin/textlint-rule-stop-words) | Detects filler words and clichés |
| [`textlint-rule-terminology`](https://github.com/sapegin/textlint-rule-terminology) | Enforces the correct spelling of technical terms |
| [`textlint-rule-terminology-zh`](https://www.npmjs.com/package/textlint-rule-terminology-zh) | Enforces the correct spelling of terms in Chinese and English |
| [`textlint-rule-ukraine`](https://github.com/damian-buho/textlint-rule-ukraine) | Detects russified spellings of Ukrainian place and personal names |
| [`textlint-rule-unexpanded-acronym`](https://github.com/textlint-rule/textlint-rule-unexpanded-acronym) | Detects acronyms that are never expanded |
| [`textlint-rule-use-si-units`](https://github.com/kn1cht/textlint-rule-use-si-units) | Disallows units outside the International System of Units (SI) |
| [`textlint-rule-write-good`](https://github.com/textlint-rule/textlint-rule-write-good) | Checks English style with write-good |
| [`textlint-rule-zh-half-and-full-width-bracket`](https://github.com/ylc395/textlint-rule-zh-half-and-full-width-bracket) | Checks full-width and half-width brackets in Chinese text |

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
