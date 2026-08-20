---
name: google-calendar
description: gws で Google カレンダーにスケジュールを登録するためのスキルです
---

このスキルは `gws` コマンドを使用して Google カレンダーに新しいイベントを登録します。

## 使い方

`gws calendar events insert` コマンドと `--json` オプションを使ってイベントを登録します。
`--json` オプションには、後述する **JSON の構造** を参考にして、イベントの詳細を JSON 形式で渡してください。

### 実行コマンドの基本形

```sh
gws calendar events insert --params '{"calendarId": "primary"}' --json '（ここに JSON 文字列を記述）'
```

### JSON の構造

`--json` に渡す JSON は、以下のキーを持つ必要があります。

```json
{
  "summary": "（イベントのタイトル）",
  "description": "（イベントの説明詳細。タイトル自体は含めないでください）",
  "start": {
    "dateTime": "（RFC3339 形式の開始日時）",
    "timeZone": "（タイムゾーン名）"
  },
  "end": {
    "dateTime": "（RFC3339 形式の終了日時）",
    "timeZone": "（タイムゾーン名）"
  }
}
```

### `description` の書き方

イベントの説明（`description`）には、以下のルールに従って内容を構成してください。

- **説明本文およびリンク**：ユーザーから指示された詳細な説明を記述する。タイトルそのものは重複して含めない。ユーザーから指示された関連リンクがある場合はその URL をそのまま含める
- **メタデータ（説明の末尾に空行を挟んで記述）**：説明の末尾に以下のメタデータを必ず含める
  - **`Registered by`**：`gemini cli`
  - **`Directory`**：コマンド実行時のカレントディレクトリ（ホームディレクトリからの相対パス）

#### `description` の記述例

```
ユーザーから指示された説明詳細。
https://github.com/...

---
Registered by: gemini cli
Directory: （カレントディレクトリ）
```

**注意点:**

- JSON 文字列は、シェルの引数として渡すために、適切にエスケープされた1行の文字列にする必要があります
- 日時（`dateTime`）は ` YYYY-MM-DDTHH:MM:SS+09:00 ` のような RFC 3339 形式で指定してください
- タイムゾーン（`timeZone`）は ` Asia/Tokyo ` のように指定してください
