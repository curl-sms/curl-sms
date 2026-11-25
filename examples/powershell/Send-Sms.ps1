<#
.SYNOPSIS
    Send an SMS with curl-sms from PowerShell.

.DESCRIPTION
    Works in Windows PowerShell 5.1 and PowerShell 7+. Keeps umlauts and emoji
    intact by sending the body as UTF-8 bytes. Reads the API key from
    $env:CURLSMS_API_KEY unless -ApiKey is given.

.EXAMPLE
    $env:CURLSMS_API_KEY = 'cs_test_...'
    ./Send-Sms.ps1 -Receiver '+4915123456789' -Text 'Hello from PowerShell'
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $Receiver,
    [Parameter(Mandatory)] [string] $Text,
    [string] $ApiKey = $env:CURLSMS_API_KEY,
    [string] $IdempotencyKey = [guid]::NewGuid().ToString()
)

if (-not $ApiKey) {
    throw 'Set CURLSMS_API_KEY to a key from https://curl-sms.com/app/keys'
}

$json = @{ receiver = $Receiver; body = $Text } | ConvertTo-Json -Compress
$params = @{
    Method      = 'Post'
    Uri         = 'https://curl-sms.com/api/sms/send'
    Headers     = @{
        Authorization     = "Bearer $ApiKey"
        'Accept-Language' = 'en'
        'Idempotency-Key' = $IdempotencyKey
    }
    ContentType = 'application/json; charset=utf-8'
    Body        = [System.Text.Encoding]::UTF8.GetBytes($json)
    TimeoutSec  = 15
}

try {
    $sms = Invoke-RestMethod @params
    Write-Output "$($sms.id) $($sms.status) $($sms.segments) part(s) EUR $($sms.price)"
}
catch {
    $detail = $_.ErrorDetails.Message
    if ($detail) {
        $err = ($detail | ConvertFrom-Json).error
        throw "$($err.code): $($err.message)"
    }
    throw
}
