package main

import (
	"bufio"
	"bytes"
	"encoding/base64"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"log"
	"net"
	"os"
	"os/exec"
	"os/signal"
	"syscall"
)

var powershellPath string

func init() {
	powershellPath = getPowerShellPath()
}

type NotificationMessage struct {
	App     string `json:"app"`
	Title   string `json:"title"`
	Message string `json:"message"`
	URL     string `json:"url"`
}

func main() {
	app := flag.String("app", "go-win-toast", "Application name")
	title := flag.String("title", "no title", "Notification title")
	message := flag.String("message", "no message", "Notification message")
	url := flag.String("url", "", "URL to open when clicked")
	socket := flag.String("socket", "", "Unix domain socket path to listen on")

	flag.Parse()

	if *socket != "" {
		if err := startSocketServer(*socket, *app, *title, *message, *url); err != nil {
			log.Fatalln(err)
		}
	} else {
		if err := showNotification(*app, *title, *message, *url); err != nil {
			log.Fatalln(err)
		}
	}
}

func showNotification(app, title, message, url string) error {
	jsonData := NotificationMessage{
		App:     app,
		Title:   title,
		Message: message,
		URL:     url,
	}

	jsonBytes, err := json.Marshal(jsonData)
	if err != nil {
		return fmt.Errorf("failed to marshal JSON: %w", err)
	}

	encodedJSON := base64.StdEncoding.EncodeToString(jsonBytes)

	cmd := exec.Command(powershellPath, "-NoProfile", "-NonInteractive", "-Command", `
		$base64Input = $input
		$jsonBytes = [System.Convert]::FromBase64String($base64Input)
		$jsonString = [System.Text.Encoding]::UTF8.GetString($jsonBytes)
		$data = $jsonString | ConvertFrom-Json

		[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
		$template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

		# https://learn.microsoft.com/ja-jp/windows/apps/design/shell/tiles-and-notifications/toast-schema
		$template.GetElementsByTagName('toast').Item(0).SetAttribute('activationType', 'protocol')
		$template.GetElementsByTagName('toast').Item(0).SetAttribute('launch', $data.url)
		$template.GetElementsByTagName('text').Item(0).InnerText = $data.title;
		$template.GetElementsByTagName('text').Item(1).InnerText = $data.message;

		[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($data.app).Show($template);
	`)

	cmd.Stdin = bytes.NewReader([]byte(encodedJSON))
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to execute PowerShell: %w", err)
	}

	return nil
}

func startSocketServer(socketPath, defaultApp, defaultTitle, defaultMessage, defaultURL string) error {
	if _, err := os.Stat(socketPath); err == nil {
		if err := os.Remove(socketPath); err != nil {
			return fmt.Errorf("failed to remove existing socket file: %w", err)
		}
	}

	listener, err := net.Listen("unix", socketPath)
	if err != nil {
		return fmt.Errorf("failed to listen on unix socket: %w", err)
	}
	defer listener.Close()
	defer os.Remove(socketPath)

	log.Printf("Listening on unix socket: %s", socketPath)

	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGHUP, syscall.SIGTERM)

	go func() {
		sig := <-sigChan
		log.Printf("shutting down: %v", sig)
		listener.Close()
		sig = <-sigChan
		log.Printf("force down: %v", sig)
		os.Remove(socketPath)
		os.Exit(0)
	}()

	for {
		conn, err := listener.Accept()
		if err != nil {
			if errors.Is(err, net.ErrClosed) {
				break
			}
			log.Printf("Failed to accept connection: %v", err)
			continue
		}
		go handleConnection(conn, defaultApp, defaultTitle, defaultMessage, defaultURL)
	}

	return nil
}

func handleConnection(conn net.Conn, defaultApp, defaultTitle, defaultMessage, defaultURL string) {
	defer conn.Close()

	scanner := bufio.NewScanner(conn)
	for scanner.Scan() {
		line := scanner.Text()

		var msg NotificationMessage
		if err := json.Unmarshal([]byte(line), &msg); err != nil {
			log.Printf("failed to parse JSON: %v", err)
			continue
		}

		app := mergeString(msg.App, defaultApp)
		title := mergeString(msg.Title, defaultTitle)
		message := mergeString(msg.Message, defaultMessage)
		url := mergeString(msg.URL, defaultURL)

		log.Printf("showing notification: app=%s, title=%s, message=%s, url=%s", app, title, message, url)
		if err := showNotification(app, title, message, url); err != nil {
			log.Printf("failed to show notification: %v", err)
			continue
		}
	}

	if err := scanner.Err(); err != nil {
		log.Printf("connection error: %v", err)
	}
}

func mergeString(jsonValue, defaultValue string) string {
	if jsonValue != "" {
		return jsonValue
	}
	return defaultValue
}

func getPowerShellPath() string {
	windowsPath := `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`

	cmd := exec.Command("wslpath", windowsPath)
	output, err := cmd.Output()
	if err != nil {
		return "/c/Windows/system32/WindowsPowerShell/v1.0/powershell.exe"
	}
	1
	return string(bytes.TrimSpace(output))
}
