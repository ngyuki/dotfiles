# Entry Examples

すべてのフィールドを含む、整形されたエントリーの具体的な例。

## Learning: Correction

```
## [LRN-20250115-001] correction

**Logged**: 2025-01-15T10:30:00Z
**Priority**: high
**Status**: pending
**Area**: tests

### Summary

pytest の fixture はデフォルトで関数スコープであると誤って思い込んでいた

### Details

テストの fixture を書くとき、すべての fixture は関数スコープだと思い込んでいました。
ユーザーからの指摘で、関数スコープがデフォルトであるものの、このコードベースの規約では
テストのパフォーマンスを向上させるために、データベース接続にはモジュールスコープの
fixture を使用していることがわかりました。

### Suggested Action

高コストなセットアップ（DB、ネットワーク）を伴う fixture を作成する場合、
デフォルトで関数スコープにする前に、既存の fixture のスコープパターンを確認する。

### Metadata

- Source: user_feedback
- Related Files: tests/conftest.py
- Tags: pytest, testing, fixtures

---
```

## Learning: Knowledge Gap (Resolved)

```
## [LRN-20250115-002] knowledge_gap

**Logged**: 2025-01-15T14:22:00Z
**Priority**: medium
**Status**: resolved
**Area**: config

### Summary

プロジェクトはパッケージ管理に npm ではなく pnpm を使用している

### Details

`npm install` を実行しようとしましたが、プロジェクトは pnpm ワークスペースを使用しています。
ロックファイルは `package-lock.json` ではなく `pnpm-lock.yaml` です。

### Suggested Action

npm を想定する前に `pnpm-lock.yaml` または `pnpm-workspace.yaml` がないか確認する。
このプロジェクトでは `pnpm install` を使用する。

### Metadata

- Source: error
- Related Files: pnpm-lock.yaml, pnpm-workspace.yaml
- Tags: package-manager, pnpm, setup

### Resolution

- **Resolved**: 2025-01-15T14:30:00Z
- **Commit/PR**: N/A - knowledge update
- **Notes**: Added to CLAUDE.md for future reference

---
```

## Learning: Promoted to AGENTS.md

```
## [LRN-20250115-003] best_practice

**Logged**: 2025-01-15T16:00:00Z
**Priority**: high
**Status**: promoted
**Promoted**: AGENTS.md
**Area**: backend

### Summary

API レスポンスにはリクエストヘッダーの相関 ID を含める必要がある

### Details

すべての API レスポンスは、リクエストの X-Correlation-ID ヘッダーを
そのまま返す必要があります。これは分散トレーシングに必要です。
このヘッダーのないレスポンスは、オブザーバビリティパイプラインを破壊します。

### Suggested Action

API ハンドラには常に相関 ID のパススルーを含める。

### Metadata

- Source: user_feedback
- Related Files: src/middleware/correlation.ts
- Tags: api, observability, tracing

---
```

## Error Entry

```
## [ERR-20250115-A3F] docker_build

**Logged**: 2025-01-15T09:15:00Z
**Priority**: high
**Status**: pending
**Area**: infra

### Summary

M1 Mac での Docker ビルドがプラットフォームの不一致で失敗する

### Error

```
error: failed to solve: python:3.11-slim: no match for platform linux/arm64
```

### Context

- Command: `docker build -t myapp .`
- Dockerfile uses `FROM python:3.11-slim`
- Running on Apple Silicon (M1/M2)

### Suggested Fix

プラットフォームフラグを追加する: `docker build --platform linux/amd64 -t myapp .`
または Dockerfile を更新する: `FROM --platform=linux/amd64 python:3.11-slim`

### Metadata

- Reproducible: yes
- Related Files: Dockerfile

---
```

## Error Entry: Recurring Issue

```
## [ERR-20250120-B2C] api_timeout

**Logged**: 2025-01-20T11:30:00Z
**Priority**: critical
**Status**: pending
**Area**: backend

### Summary

チェックアウト中にサードパーティ決済 API がタイムアウトする

### Error

```
TimeoutError: Request to payments.example.com timed out after 30000ms
```

### Context

- Command: POST /api/checkout
- タイムアウトは 30s に設定
- ピーク時（昼休み、夕方）に発生

### Suggested Fix

指数関数的バックオフを伴うリトライを実装する。サーキットブレーカーパターンの検討。

### Metadata

- Reproducible: yes (during peak hours)
- Related Files: src/services/payment.ts
- See Also: ERR-20250115-X1Y, ERR-20250118-Z3W

---
```

## Feature Request

```
## [FEAT-20250115-001] export_to_csv

**Logged**: 2025-01-15T16:45:00Z
**Priority**: medium
**Status**: pending
**Area**: backend

### Requested Capability

分析結果を CSV 形式でエクスポートする

### User Context

ユーザーは週次レポートを実行し、技術者ではない関係者と Excel で
結果を共有する必要がある。現在は手動で出力をコピーしている。

### Complexity Estimate

低い

### Suggested Implementation

analyze コマンドに `--output csv` フラグを追加する。標準の csv モジュールを使用する。
既存の `--output json` パターンを拡張できる可能性がある。

### Metadata

- Frequency: recurring
- Related Features: analyze command, json output

---
```

## Feature Request: Resolved

```
## [FEAT-20250110-002] dark_mode

**Logged**: 2025-01-10T14:00:00Z
**Priority**: low
**Status**: resolved
**Area**: frontend

### Requested Capability

ダッシュボードのダークモード対応

### User Context

ユーザーは夜遅くまで作業し、明るいインターフェースは目が疲れると感じている。
他の何人かのユーザーも非公式にこの件に言及している。

### Complexity Estimate

中

### Suggested Implementation

色には CSS 変数を使用する。ユーザー設定にトグルを追加する。
システム設定の検出を検討する。

### Metadata

- Frequency: recurring
- Related Features: user settings, theme system

### Resolution

- **Resolved**: 2025-01-18T16:00:00Z
- **Commit/PR**: #142
- **Notes**: システム設定の検出と手動トグルで実装

---
```

## Learning: Promoted to Skill

```
## [LRN-20250118-001] best_practice

**Logged**: 2025-01-18T11:00:00Z
**Priority**: high
**Status**: promoted_to_skill
**Skill-Path**: skills/docker-m1-fixes
**Area**: infra

### Summary

Apple Silicon での Docker ビルドがプラットフォームの不一致で失敗する

### Details

M1/M2 Mac で Docker イメージをビルドする際、ベースイメージに ARM64 バリアントが
ないためビルドが失敗します。これは多くの開発者に影響する一般的な問題です。

### Suggested Action

`docker build` コマンドに `--platform linux/amd64` を追加するか、
Dockerfile で `FROM --platform=linux/amd64` を使用する。

### Metadata

- Source: error
- Related Files: Dockerfile
- Tags: docker, arm64, m1, apple-silicon
- See Also: ERR-20250115-A3F, ERR-20250117-B2D

---
```

## 抽出されたスキルの例

上記の学習がスキルとして抽出されると、次のようになります。

**File**: `skills/docker-m1-fixes/SKILL.md`

```
---
name: docker-m1-fixes
description: Apple Silicon (M1/M2) での Docker ビルドの失敗を修正します。プラットフォームの不一致エラーで docker build が失敗する場合に使用します。
---

# Docker M1 修正

Apple Silicon Mac での Docker ビルド問題の解決策。

## クイックリファレンス

|                Error                |                    Fix                    |
| ----------------------------------- | ----------------------------------------- |
| `no match for platform linux/arm64` | Add `--platform linux/amd64` to build     |
| Image runs but crashes              | Use emulation or find ARM-compatible base |

## 問題点

多くの Docker ベースイメージには ARM64 バリアントがありません。
Apple Silicon (M1/M2/M3) でビルドする際、Docker はデフォルトで
ARM64 イメージをプルしようとし、プラットフォームの不一致エラーが発生します。

## 解決策

### Option 1：ビルドフラグ（推奨）

ビルドコマンドにプラットフォームフラグを追加します。

\`\`\`sh
docker build --platform linux/amd64 -t myapp .
\`\`\`

### Option 2：Dockerfile の変更

FROM 命令でプラットフォームを指定します。

\`\`\`dockerfile
FROM --platform=linux/amd64 python:3.11-slim
\`\`\`

### Option 3：Docker Compose

サービスにプラットフォームを追加します。

\`\`\`yaml
services:
  app:
    platform: linux/amd64
    build: .
\`\`\`

## トレードオフ

| アプローチ |             長所             |             短所             |
| ---------- | ---------------------------- | ---------------------------- |
| Build flag | ファイルの変更なし           | フラグを覚えておく必要がある |
| Dockerfile | 明示的でバージョン管理される | すべてのビルドに影響する     |
| Compose    | 開発に便利                   | compose が必要               |

## パフォーマンスに関する注意

ARM64 上で AMD64 イメージを実行すると、Rosetta 2 エミュレーションが使用されます。
これは開発には機能しますが、速度が遅くなる可能性があります。本番環境では、
可能な場合は ARM ネイティブの代替を探してください。

## ソース

- Learning ID: LRN-20250118-001
- Category: best_practice
- Extraction Date: 2025-01-18
```
