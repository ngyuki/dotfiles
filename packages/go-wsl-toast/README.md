# go-wsl-toast

WSL から Windows のトースト通知を表示する Go プログラムです。

## 使い方

```bash
# 基本的な使い方
go-wsl-toast -app "MyApp" -title "Hello" -message "This is a test notification"

# URL を指定して、クリック時にブラウザを開く
go-wsl-toast -app "MyApp" -title "GitHub" -message "Click to open GitHub" -url "https://github.com"
```

## コマンドライン引数

- `-app`: アプリケーション名（デフォルト: "go-wsl-toast"）
- `-title`: 通知のタイトル（デフォルト: "no title"）
- `-message`: 通知のメッセージ（デフォルト: "no message"）
- `-url`: クリック時に開く URL（デフォルト: ""）

## ソケットモード

`-socket` オプションを使用すると、Unix ドメインソケット経由で通知リクエストを受け付けるサーバーモードで起動できます。

```bash
# サーバーモードで起動
go-wsl-toast -socket /tmp/go-wsl-toast.sock

# 別のターミナルから通知を送信
echo '{"app":"MyApp","title":"Test","message":"Socket notification"}' | nc -U /tmp/go-wsl-toast.sock
```

ソケットモードでは、JSON 形式でリクエストを送信します：

```json
{
  "app": "アプリケーション名",
  "title": "タイトル",
  "message": "メッセージ",
  "url": "https://example.com"  // オプション
}
```

### systemd ユーザーサービスとして実行

systemd のユーザーモードでサービスとして実行できます

```bash
# ユニットファイルを配置してサービスを有効化
make install-systemd

# ステータス確認
systemctl --user status wsl-toast.service

# 通知を送信
echo '{"app":"MyApp","title":"Test","message":"Hello from systemd!"}' | nc -U $XDG_RUNTIME_DIR/wsl-toast.sock
```
