# wsl-toast

WSL から Windows のトースト通知を表示する Go プログラムです。

## ビルドとインストール

```sh
make
make install
```

## 使い方

```bash
# 基本的な使い方
wsl-toast -app "MyApp" -title "Hello" -message "This is a test notification"

# URL を指定して、クリック時にブラウザを開く
wsl-toast -app "MyApp" -title "GitHub" -message "Click to open GitHub" -url "https://github.com"
```

## コマンドライン引数

```
Usage of ./wsl-toast:
  -app string
        Application name (default "go-win-toast")
  -message string
        Notification message (default "no message")
  -socket string
        Unix domain socket path to listen on
  -title string
        Notification title (default "no title")
  -url string
        URL to open when clicked
```

## ソケットモード

`-socket` オプションを使用すると、Unix ドメインソケット経由で通知リクエストを受け付けるサーバーモードで起動できます。

```bash
# サーバーモードで起動
wsl-toast -socket /tmp/wsl-toast.sock

# 別のターミナルから通知を送信
echo '{"app":"MyApp","title":"Test","message":"Socket notification"}' | nc -U /tmp/wsl-toast.sock
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
