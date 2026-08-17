# Learnings

開発中に捉えられた、修正、洞察、知識のギャップ。

**Categories**: correction | knowledge_gap | best_practice
**Areas**: frontend | backend | infra | tests | docs | config
**Statuses**: pending | in_progress | resolved | wont_fix | promoted | promoted_to_skill

## Status Definitions

|     ステータス      |                  意味                  |
| ------------------- | -------------------------------------- |
| `pending`           | 未対応                                 |
| `in_progress`       | 対応中                                 |
| `resolved`          | 問題が修正されたか、知識が統合された   |
| `wont_fix`          | 対応しないと決定（理由は解決策に記載） |
| `promoted`          | AGENTS.md に昇格                       |
| `promoted_to_skill` | 再利用可能なスキルとして抽出           |

## スキル抽出フィールド

学習がスキルに昇格した場合、これらのフィールドを追加します：

```
**Status**: promoted_to_skill
**Skill-Path**: skills/skill-name
```

Example:

```
## [LRN-20250115-001] best_practice

**Logged**: 2025-01-15T10:00:00Z
**Priority**: high
**Status**: promoted_to_skill
**Skill-Path**: skills/docker-m1-fixes
**Area**: infra

### Summary
Docker ビルドがプラットフォームの不一致により Apple Silicon で失敗する
...
```

---
