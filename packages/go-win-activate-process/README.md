# win-activate-process

Windows のウィンドウを検索して最前面化・アクティブ化する Go プログラムです。
`-H windowsgui` でビルドされており、コンソールウィンドウ（黒い画面）を表示することなくバックグラウンドで動作します。
また、WSL のトースト通知クリック連携用のプロトコルハンドラー（`wsl-toast:`）機能も備えています。

## 主な機能

- **柔軟なウィンドウ検索（複合検索・AND 条件対応）**
  - タイトル名（`-title`）
  - プログラム名 / 実行ファイル名（`-prog`）
  - ウィンドウクラス名（`-class`）
  - 正規表現マッチモード（`-regex`）
- **仮想デスクトップ検索モード（`-desktop`）**
  - `prefer-current`: 現在の仮想デスクトップにあるウィンドウを最優先し、無ければ他を探索（デフォルト）
  - `only-current`: 現在の仮想デスクトップにあるウィンドウのみ対象
  - `any`: 全ての仮想デスクトップから平等に探索（Z-order 順）
- **バックグラウンド実行からの前面化対応**
  - WSL のバックグラウンド実行からでも確実に最前面化可能（`ShellExecuteEx` による子プロセス再実行）
- **トースト通知連携プロトコルハンドラー（`wsl-toast:`）**
  - Windows のカスタム URI スキームから起動され、ターミナルウィンドウの前面化と WSL 内の tmux フォーカス切り替えを同時に実行
  - tmux の切り替えは `session:window.pane` 形式でセッション・ウィンドウ・ペインを一括切り替え
  - `WSLENV` 機構による安全な環境変数渡しと入力値のホワイトリスト検証により、シェルインジェクションを防止
- **プロトコル登録機能**
  - Windows レジストリ（`HKCU\Software\Classes\wsl-toast`）へのプロトコルハンドラー自動登録・解除

## ビルドとインストール

```sh
# ビルド
make

# インストール（%USERPROFILE%\bin への配置とプロトコル登録）
make install
```

## 使い方

### 1. CLI オプション

```bash
# タイトルで検索（部分一致）
win-activate-process.exe -title "Visual Studio Code"

# プログラム名で検索
win-activate-process.exe -prog "wezterm-gui.exe"

# ウィンドウクラス名で検索
win-activate-process.exe -class "Alacritty"

# 組み合わせ（AND 条件）
win-activate-process.exe -title "WSL:fedora" -prog "wezterm-gui.exe"

# 正規表現マッチ
win-activate-process.exe -title "^dotfiles" -regex

# 仮想デスクトップ指定
win-activate-process.exe -title "WSL:fedora" -desktop only-current
win-activate-process.exe -title "WSL:fedora" -desktop any

# tmux の切り替え（distro や client は省略可能）
win-activate-process.exe -tmux 'distro=fedora;client=/dev/pts/0;$1:@3.%7'

# 後方互換（フラグなし単一引数は -title 扱い）
win-activate-process.exe "Visual Studio Code"
```

### 2. プロトコルハンドラー（`wsl-toast:`）

トースト通知のクリック時などに Windows Shell から呼び出されることを想定しています。

```bash
win-activate-process.exe 'wsl-toast://activate?title=WSL:fedora&tmux=distro=fedora;client=/dev/pts/0;$1:@3.%7'
```

#### クエリパラメータ

CLI オプションと同じ名前でパラメータを指定できます：

- `title`: ウィンドウタイトル
- `prog`: プログラム名（exe 名）
- `class`: ウィンドウクラス名
- `regex`: 正規表現マッチ（`true` または `1`）
- `desktop`: 仮想デスクトップモード（`prefer-current`, `only-current`, `any`）
- `tmux`: tmux 切り替え指定（例: `distro=fedora;client=/dev/pts/0;dotfiles:@0.%0`）

### 3. プロトコルハンドラーのレジストリ登録・解除

管理者権限は不要です（現在のユーザーの `HKCU` に登録されます）。

```bash
# プロトコルの登録
win-activate-process.exe -register-protocol

# プロトコルの解除
win-activate-process.exe -unregister-protocol
```
