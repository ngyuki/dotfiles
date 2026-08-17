# Skill Template

学習から抽出したスキルを作成するためのテンプレート。コピーしてカスタマイズしてください。

---

## SKILL.md Template

```
---
name: スキル名
description: >
  このスキルをいつ、なぜ使うのかの簡潔な説明。トリガー条件を含む。
---

# スキル名

このスキルが解決する問題とその由来を説明する簡単な紹介。

## Quick Reference

|  Situation  |   Action   |
| ----------- | ---------- |
| [Trigger 1] | [Action 1] |
| [Trigger 2] | [Action 2] |

## 背景

なぜこの知識が重要なのか。それが防ぐ問題は何か。元の学習からのコンテキスト。

## 解決策

### ステップバイステップ

1. コードまたはコマンドを含む最初のステップ
2. 2番目のステップ
3. 検証ステップ

### コード例

\`\`\`language
// 解決策を示すコード例
\`\`\`

## 一般的なバリエーション

- **バリエーション A**: 説明と対処法
- **バリエーション B**: 説明と対処法

## 注意点

- 警告またはよくある間違い #1
- 警告またはよくある間違い #2

## 関連

- 関連ドキュメントへのリンク
- 関連スキルへのリンク

## ソース

学習エントリーから抽出。
- **Learning ID**: LRN-YYYYMMDD-XXX
- **Original Category**: correction | insight | knowledge_gap | best_practice
- **Extraction Date**: YYYY-MM-DD
```

---

## 最小テンプレート

すべてのセクションを必要としない単純なスキル向け：

```
---
name: スキル名
description: >
  このスキルが何をするか、いつ使うか。
---

# スキル名

[一文で問題提起]

## 解決策

[コード/コマンド付きの直接的な解決策]

## ソース

- Learning ID: LRN-YYYYMMDD-XXX
```

---

## スクリプト付きテンプレート

実行可能なヘルパーを含むスキル向け：

```
---
name: スキル名
description: >
  このスキルが何をするか、いつ使うか。
---

# スキル名

[はじめに]

## Quick Reference

|         Command         |    Purpose     |
| ----------------------- | -------------- |
| `./scripts/helper.sh`   | [What it does] |
| `./scripts/validate.sh` | [What it does] |

## Usage

### Automated (Recommended)

\`\`\`sh
./skills/skill-name/scripts/helper.sh [args]
\`\`\`

### Manual Steps

1. Step one
2. Step two

## Scripts

|        Script         |    Description     |
| --------------------- | ------------------ |
| `scripts/helper.sh`   | Main utility       |
| `scripts/validate.sh` | Validation checker |

## Source

- Learning ID: LRN-YYYYMMDD-XXX
```

---

## 命名規則

- **スキル名**: 小文字、スペースはハイフン
  - Good: `docker-m1-fixes`, `api-timeout-patterns`
  - Bad: `Docker_M1_Fixes`, `APITimeoutPatterns`

- **説明**: アクション動詞で始め、トリガーに言及する
  - Good: Apple Silicon での Docker ビルドの失敗を処理します。ビルドがプラットフォームの不一致で失敗した場合に使用します。
  - Bad: Docker のこと

- **ファイル**:
  - `SKILL.md` - 必須、メインのドキュメント
  - `scripts/` - オプション、実行可能コード
  - `references/` - オプション、詳細ドキュメント
  - `assets/` - オプション、テンプレート

---

## Extraction Checklist

Before creating a skill from a learning:

- [ ] Learning is verified (status: resolved)
- [ ] Solution is broadly applicable (not one-off)
- [ ] Content is complete (has all needed context)
- [ ] Name follows conventions
- [ ] Description is concise but informative
- [ ] Quick Reference table is actionable
- [ ] Code examples are tested
- [ ] Source learning ID is recorded

After creating:

- [ ] Update original learning with `promoted_to_skill` status
- [ ] Add `Skill-Path: skills/skill-name` to learning metadata
- [ ] Test skill by reading it in a fresh session
