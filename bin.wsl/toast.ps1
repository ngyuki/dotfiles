# powershell.exe -Sta -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File toast.ps1 -title "title" -message "message" -url "https://example.com"

param(
    [string]$title   = 'no title',
    [string]$message = 'no message',
    [string]$url     = ''
)

[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
$template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

# https://learn.microsoft.com/ja-jp/windows/apps/design/shell/tiles-and-notifications/toast-schema
$template.GetElementsByTagName('toast').Item(0).SetAttribute('activationType', 'protocol')
$template.GetElementsByTagName('toast').Item(0).SetAttribute('launch', $url)
$template.GetElementsByTagName('text').Item(0).InnerText = $title;
$template.GetElementsByTagName('text').Item(1).InnerText = $message;

[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier().Show($template);
