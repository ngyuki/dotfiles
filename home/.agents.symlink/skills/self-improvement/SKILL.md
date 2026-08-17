---
# https://github.com/pskoett/pskoett-ai-skills/tree/main/skills/self-improvement

name: self-improvement
description: >
  継続的な改善を可能にするために、学習、エラー、修正、機能リクエストを記録する。
  使用場面:
  (1) ユーザーがエージェントの過ちを指摘したとき。
  (2) エージェントがプロジェクト特有の知識に気づいたとき。
  (3) エージェントが自身の知識が古くなっている、または間違っていることに気づいたとき。
  (4) エージェントが繰り返し発生するタスクに対してより良いアプローチを発見したとき。
  (5) コマンドや操作が失敗したとき。
  (6) ユーザーが存在しない機能を要求したとき。
---

# 自己改善スキル (Self-Improvement Skill)

継続的な改善のために、学習内容やエラーを Markdown ファイルに記録します。
コーディングエージェントは、後でこれらを処理して修正に繋げることができ、重要な学習内容はプロジェクトのメモリへと昇格されます。

## セットアップ

プロジェクトのルートディレクトリに `.learnings/` ディレクトリが存在しない場合は作成します：

```sh
mkdir -p .learnings/
```

`assets/` からファイルテンプレート（`LEARNINGS.md`, `ERRORS.md`, `FEATURE_REQUESTS.md`）をコピーするか、ヘッダーを含むファイルを作成します。

## クイックリファレンス

|                  状況                  |                         アクション                          |
| -------------------------------------- | ----------------------------------------------------------- |
| ユーザーが過ちを指摘したとき           | `.learnings/LEARNINGS.md` に記録 (カテゴリ `correction`)    |
| エージェントの知識が古かった           | `.learnings/LEARNINGS.md` に記録 (カテゴリ `knowledge_gap`) |
| エージェントの知識が間違っている       | `.learnings/LEARNINGS.md` に記録 (カテゴリ `knowledge_gap`) |
| プロジェクトの規約を学んだとき         | `.learnings/LEARNINGS.md` に記録 (カテゴリ `knowledge_gap`) |
| より良いアプローチを発見した           | `.learnings/LEARNINGS.md` に記録 (カテゴリ `best_practice`) |
| コマンドや操作が失敗した               | `.learnings/ERRORS.md` に記録                               |
| ユーザーが存在しない機能を要求したとき | `.learnings/FEATURE_REQUESTS.md` に記録                     |
| 既存のエントリと類似している           | `**See Also**` でリンクし、優先度の引き上げを検討           |

## ベストプラクティス

1. **すぐに記録する** - 問題の直後が最もコンテキストが鮮明です
2. **具体的に記述する** - 将来のエージェントが素早く理解できるようにします
3. **再現手順を含める** - 特にエラーの場合に重要です
4. **関連ファイルをリンクする** - 修正が容易になります
5. **具体的な修正案を提示する** - 単に「調査する」だけではなく
6. **一貫したカテゴリを使用する** - フィルタリングを可能にします
7. **積極的に昇格させる** - 迷った場合は `AGENTS.md` に追加します
8. **定期的に見直す** - 古くなった学習内容は価値を失います

## ファイル更新時の注意事項

`.learnings/` のファイルを更新するとき、エージェントの設定によっては当該ディレクトリが不可視となっている可能性があるため、ファイルが存在しない場合はシェルコマンドを用いて読み込むこと。

## 記録フォーマット

### 学習エントリ (Learning Entry)

`.learnings/LEARNINGS.md` に追記：

```
## [LRN-YYYYMMDD-XXX] category

**Logged**: ISO-8601 timestamp
**Priority**: low | medium | high | critical
**Status**: pending
**Area**: frontend | backend | infra | tests | docs | config

### Summary

学習内容の 1 行説明

### Details

全体的な状況：何が起きたか、何が間違っていたか、何が正しいか

### Suggested Action

具体的な修正または改善策

### Metadata

- Source: conversation | error | user_feedback
- Related Files: path/to/file.ext
- Tags: tag1, tag2
- See Also: LRN-20250110-001 (既存のエントリに関連する場合)
- Recurrence-Count: 1 (optional)
- First-Seen: 2025-01-15 (optional)
- Last-Seen: 2025-01-15 (optional)

---
```

### エラーエントリ (Error Entry)

`.learnings/ERRORS.md` に追記：

```
## [ERR-YYYYMMDD-XXX] skill_or_command_name

**Logged**: ISO-8601 timestamp
**Priority**: high
**Status**: pending
**Area**: frontend | backend | infra | tests | docs | config

### Summary

何が失敗したかの簡単な説明

### Error

```
実際のエラーメッセージまたは出力
```

### Context

- 試みたコマンド/操作
- 使用した入力またはパラメータ
- 関連する場合は環境の詳細

### Suggested Fix

特定可能な場合、解決につながる可能性のある内容

### Metadata

- Reproducible: yes | no | unknown
- Related Files: path/to/file.ext
- See Also: ERR-20250110-001 (繰り返し発生する場合)

---
```

### 機能リクエストエントリ (Feature Request Entry)

`.learnings/FEATURE_REQUESTS.md` に追記：

```
## [FEAT-YYYYMMDD-XXX] capability_name

**Logged**: ISO-8601 timestamp
**Priority**: medium
**Status**: pending
**Area**: frontend | backend | infra | tests | docs | config

### Requested Capability

ユーザーが実行したかったこと

### User Context

なぜそれが必要だったか、どのような問題を解決しようとしているか

### Complexity Estimate

simple | medium | complex

### Suggested Implementation

これをどのように構築できるか、何を拡張できるか

### Metadata

- Frequency: first_time | recurring
- Related Features: existing_feature_name
---
```

## ID 生成

フォーマット: `TYPE-YYYYMMDD-XXX`

- TYPE: `LRN` (learning), `ERR` (error), `FEAT` (feature)
- YYYYMMDD: 現在の日付
- XXX: 連番（例： `001`, `002`）

例: `LRN-20250115-001`, `ERR-20250115-002`, `FEAT-20250115-003`

## エントリの解決

問題が修正されたら、エントリを更新します：

1. `**Status**: pending` を `**Status**: resolved` に変更します。
2. Metadata の後に Resolution ブロックを追加します：

```
### Resolution

- **Resolved**: 2025-01-16T09:00:00Z
- **Commit/PR**: https://github.com/ORDER/REPO/issues/nnnn or #nnnn
- **Notes**: 行われた作業の簡単な説明
```

その他のステータス値：

- `in_progress`: 現在対応中
- `wont_fix`: 対応しないことを決定（ Resolution の notes に理由を追加）
- `promoted`: AGENTS.md
- `promoted_to_skill` - 再利用可能なスキルとして抽出（「自動スキル抽出」を参照）

## 繰り返しパターンの検出

既存の項目と類似した内容を記録する場合：

1. **Search first**: `grep -r "keyword" .learnings/`
2. **Link entries**: Add `**See Also**: ERR-20250110-001` in Metadata
3. **Bump priority** if issue keeps recurring
4. **Consider systemic fix**: Recurring issues often indicate:
   - Missing documentation or automation (→ add to AGENTS.md)
   - Architectural problem (→ create tech debt ticket)

## Priority Guidelines

|  Priority  |                                 When to Use                                  |
| ---------- | ---------------------------------------------------------------------------- |
| `critical` | コア機能をブロックする、データ損失のリスクがある、セキュリティ上の問題がある |
| `high`     | 大きな影響がある、一般的なワークフローに影響する、繰り返し発生する問題である |
| `medium`   | 中程度の影響がある、回避策が存在する                                         |
| `low`      | 些細な不便、稀なケース、あれば望ましい機能                                   |

## Area Tags

コードベースの領域ごとに学習内容を絞り込むために使用します。

|    Area    |                   Scope                    |
| ---------- | ------------------------------------------ |
| `frontend` | UI, components, client-side code           |
| `backend`  | API, services, server-side code            |
| `infra`    | CI/CD, deployment, Docker, cloud           |
| `tests`    | Test files, testing utilities, coverage    |
| `docs`     | Documentation, comments, READMEs           |
| `config`   | Configuration files, environment, settings |

## プロジェクトメモリへの昇格

### 昇格のタイミング

- 学習内容が複数のファイル/機能にまたがって適用される場合
- すての貢献者（人間または AI ）が知っておくべき知識である場合
- 繰り返し発生するミスを防ぐことができる場合
- プジェクト固有の規約を文書化する場合

### 昇格方法

- 学習内容を簡潔な規則や事実へと凝縮する
- `AGENTS.md` の適切なセクションに追加、または既存のセクションを修正する
- 元の学習エントリの Metadata を更新する
    - `**Status**: Status`
    - `**Promoted**: AGENTS.md`

### 昇格の例

**学習内容**（冗長）

```
プロジは pnpm ワークスペースを使用しています。`npm install` を試みましたが失敗しました。
ロックファイルは `pnpm-lock.yaml` です。 `pnpm install` を使用する必要があります。
```

**AGENTS.md**（簡潔）

```
## ビルドと依存関係

- npm ではなく pnpm を使用すること
```

**学習内容** （冗長）：

```
API エンドポイントを変更するときは、TypeScript クライアントを再生成する必要があります。
これを忘れると、実行時に型不一致が発生します。
```

**AGENTS.md 内** （実行可能）：

```
## API 変更後

1. クライアントの再生成: `pnpm run generate:api`
2. 型エラーのチェック: `pnpm tsc --noEmit`
```

## 自動スキル抽出

学習内容が再利用可能なスキルにするのに十分な価値がある場合は、学習内容をスキルとして抽出します。

### スキル抽出基準

以下の **いずれか** が当てはまる場合、学習内容はスキル抽出の対象となります。

|          基準          |                           説明                           |
| ---------------------- | -------------------------------------------------------- |
| **繰り返し発生する**   | 2 つ以上の同様の問題への `See Also` リンクがある         |
| **検証済みである**     | ステータスが `resolved` で、機能する修正がある           |
| **自明ではない**       | 発見するために実際のデバッグや調査が必要だった           |
| **広く適用可能である** | プロジェクト固有ではなく、他のコードベースでも有用である |
| **ユーザーによる指摘** | ユーザーが「これをスキルとして保存して」などの発言をした |

### 抽出ワークフロー

1. **候補の特定**: 学習内容が抽出基準を満たしている
2. **SKILL.md 作成**: 学習内容を元に適切なスキル名でスキルを作成する
3. **学習内容の更新**: ステータスを `promoted_to_skill` に設定し、`Skill-Path` を追加する
4. **検証**: 新しいセッションでスキルを読み込み、自己完結していることを確認する

### SKILL.md 作成

1. `skills/<skill-name>/SKILL.md` を作成します。
2. `assets/SKILL-TEMPLATE.md` のテンプレートを使用します。
3. [Agent Skills 仕様](https://agentskills.io/specification)に従います：
    - YAML フロントマターに `name` と `description` を含める
    - 名前はフォルダ名と一致させる必要がある
    - スキルフォルダ内に README.md を含めない

### スキル抽出検出トリガー

学習内容をスキルにすべきシグナルに注意を払います。

**対話内:**
- 「これをスキルとして保存して」
- 「これに何度も遭遇している」
- 「これは他のプロジェクトでも役に立ちそうだ」
- 「このパターンを覚えておいて」

**学習エントリ内:**
- 複数の `See Also` リンク（繰り返し発生する問題）
- 高い優先度 ＋ 解決済み（ resolved ）のステータス
- カテゴリ： `best_practice` で広く適用可能
- 解決策を称賛するユーザーからのフィードバック

### スキルの品質ゲート

抽出する前に、以下を検証してください。

- [ ] 解決策がテストされ、動作していること
- [ ] 元のコンテキストがなくても説明が明確であること
- [ ] コード例が自己完結していること
- [ ] プロジェクト固有のハードコードされた値がないこと
- [ ] スキルの命名規則（小文字、ハイフン）に従っていること
