$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:3000/')
$listener.Start()
Write-Host 'Server running on http://localhost:3000'

while ($listener.IsListening) {
  $context = $listener.GetContext()
  $request = $context.Request
  $response = $context.Response
  $localPath = $request.Url.LocalPath

  if ($localPath -eq '/') { $localPath = '/index.html' }

  $filePath = Join-Path 'c:\freelance rajan site' ($localPath -replace '/', '\')

  if (Test-Path $filePath) {
    $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
    $mime = switch ($ext) {
      '.html' { 'text/html' }
      '.css'  { 'text/css' }
      '.js'   { 'application/javascript' }
      '.png'  { 'image/png' }
      '.jpg'  { 'image/jpeg' }
      '.svg'  { 'image/svg+xml' }
      default { 'application/octet-stream' }
    }
    $response.ContentType = $mime
    $buffer = [System.IO.File]::ReadAllBytes($filePath)
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
  } else {
    $response.StatusCode = 404
    $buffer = [System.Text.Encoding]::UTF8.GetBytes('Not Found')
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
  }
  $response.Close()
}
