function Test-WebSocketLatency {
    [Parameter(Mandatory = $true)]
    param([string]$uri)
    $ws = New-Object System.Net.WebSockets.ClientWebSocket
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $uri = New-Object System.Uri($uri)
    $ws.ConnectAsync($uri, [System.Threading.CancellationToken]::None).Wait()
    $sw.Stop()
    $ws.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "Close", [System.Threading.CancellationToken]::None).Wait()
    $sw.ElapsedMilliseconds
}
