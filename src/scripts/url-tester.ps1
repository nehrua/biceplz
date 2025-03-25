$urls = @(
  "https://manage.microsoft.us",
  "https://manage.microsoft.com"
)

foreach ($url in $urls) {
  try {
      $response = Invoke-WebRequest -Uri $url -UseBasicParsing
      if ($response.StatusCode -eq 200) {
          Write-Output "Successfully connected to $url"
      } else {
          Write-Output "Failed to connect to $url. Status code: $($response.StatusCode)"
      }
  } catch {
      Write-Output "Error connecting to $url"
  }
}
