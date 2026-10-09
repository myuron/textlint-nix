# AGENTS.md

## 概要

- textlint(`https://github.com/textlint/textlint`)は自然言語に対するlinterで、pluginによってルールを拡張します。
- textlint-nixを使用することで、pluginをnixで一元管理することができます。

## 課題

- textlintや一部のpluginはnixpkgsで管理されていますが、ほとんどがnixpkgsで管理されていません。
- textlint-nixをプロジェクトのflake.nixのinputsに定義し、必要なpluginを有効化することで、そのプロジェクトで利用することができるようにしたいです。

## 設計方針

- 利用者向けのインターフェースはmoduleオプション(`plugins.<name>.enable = true;`)とする。
- pluginは`buildNpmPackage`でpluginごとに個別のderivationを書く。上流がyarn / pnpmの場合のみ`fetchYarnDeps` / `fetchPnpmDeps`を使う。
- pluginのderivationはnixpkgsの`textlint.withPackages`にそのまま渡せる形にする。moduleは有効なpluginを集めて`withPackages`に渡す薄い層に留める。
- pluginはnixpkgsから取らない。nixpkgsに既にあるplugin(`textlint-rule-*` / `textlint-plugin-*`)も、このリポジトリの`pkgs/`でパッケージする。textlint本体(`textlint.withPackages`)はnixpkgsのものを使う。

## コマンド

- 整形: `nix fmt`(nixfmt)
- lint: `nix flake check`(statix + deadnix)。変更後は必ず実行する。
- flakeはgit管理下のファイルしか参照しない。新規ファイルは`git add`してから`nix build` / `nix flake check`を実行する。

## 開発フロー

- Nixコードの実装や修正(plugin追加、moduleやflakeの変更、不具合修正)は、自分で直接編集せず、`implement` workflow(`.claude/workflows/implement.js`)に依頼内容を`args`として渡して実行する。ドキュメントだけの変更は対象外。
- workflowは`planner` → `implementer` → `reviewer`を順に実行する。reviewerがマージ前に直すべき指摘を出した場合はimplementerに差し戻し、最大2回まで再レビューする。
- 結果の`status`に応じて次のように扱う。
  - `needs_decision`: plannerが依頼者にしか決められない点を見つけ、実装に進まなかった。`openQuestions`を依頼者に確認し、回答を依頼内容に加えて再実行する。
  - `approved`: 変更内容とreviewerの確認結果を依頼者に報告する。
  - `changes_remaining`: 差し戻しの上限に達しても指摘が残っている。残った指摘をそのまま依頼者に報告し、解決済みとして扱わない。
- workflowはコミットしない。コミットは依頼者に頼まれたときだけ行う。

## コミット

- Conventional Commits(`feat:`、`fix:`など)、英語で書く。
