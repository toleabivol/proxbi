#Requires -Version 7.0
<#
.SYNOPSIS
    Ensures a Proxmox server is powered on and reachable.

.DESCRIPTION
    This script is intended for Windows 11 thin clients that connect to a Proxmox server.
    It checks whether the server is already reachable. If the server is offline, it sends a
    Wake-on-LAN (WOL) magic packet to power it on and waits until the server responds to ping.
    Once the server is reachable, the script reports success and prompts the user before exiting.

.USAGE
    If your system blocks unsigned scripts, launch it via the companion
    `Start-ProxmoxServer.cmd` file included in this repository. The CMD shortcut calls
    PowerShell 7 with `-ExecutionPolicy Bypass`, which avoids the "digitally unsigned"
    error shown on default Windows installations.

.PARAMETER ServerAddress
    The IPv4 or host name of the Proxmox server that should respond to ICMP echo (ping).

.PARAMETER ServerMacAddress
    The MAC address of the Proxmox server's network interface that supports Wake-on-LAN.

.PARAMETER BroadcastAddress
    The broadcast IP address to which the WOL packet will be sent. Defaults to 255.255.255.255.

.PARAMETER WolPort
    The UDP port used for Wake-on-LAN packets (usually 7 or 9).

.PARAMETER RetryIntervalSeconds
    Delay between status checks while waiting for the server to power on.

.PARAMETER TimeoutSeconds
    Maximum amount of time to wait for the server to respond before aborting.
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$ServerAddress = "192.168.1.2",

    [Parameter()]
    [string]$ServerMacAddress = "AA-BB-CC-DD-EE-FF",

    [Parameter()]
    [string]$BroadcastAddress = "255.255.255.255",

    [Parameter()]
    [ValidateRange(1, 65535)]
    [int]$WolPort = 9,

    [Parameter()]
    [ValidateRange(1, 300)]
    [int]$RetryIntervalSeconds = 10,

    [Parameter()]
    [ValidateRange(30, 3600)]
    [int]$TimeoutSeconds = 600
)

Set-StrictMode -Version Latest

function Test-ProxmoxServerOnline {
    param(
        [Parameter(Mandatory)]
        [string]$Address
    )

    try {
        return Test-Connection -ComputerName $Address -Count 1 -Quiet -ErrorAction Stop
    }
    catch {
        return $false
    }
}

function ConvertTo-MacAddressBytes {
    param(
        [Parameter(Mandatory)]
        [string]$MacAddress
    )

    $cleanMac = $MacAddress -replace '[-:\.]', ''
    if ($cleanMac.Length -ne 12) {
        throw "The MAC address '$MacAddress' is not valid."
    }

    $bytes = New-Object byte[] 6
    for ($i = 0; $i -lt 6; $i++) {
        $bytes[$i] = [Convert]::ToByte($cleanMac.Substring($i * 2, 2), 16)
    }

    return $bytes
}

function Send-ProxmoxWakeOnLan {
    param(
        [Parameter(Mandatory)]
        [string]$MacAddress,

        [Parameter(Mandatory)]
        [string]$BroadcastAddress,

        [Parameter(Mandatory)]
        [int]$Port
    )

    $macBytes = ConvertTo-MacAddressBytes -MacAddress $MacAddress
    $packet = New-Object byte[] 102

    for ($i = 0; $i -lt 6; $i++) {
        $packet[$i] = 0xFF
    }

    for ($i = 0; $i -lt 16; $i++) {
        [Array]::Copy($macBytes, 0, $packet, 6 + ($i * $macBytes.Length), $macBytes.Length)
    }

    $udpClient = [System.Net.Sockets.UdpClient]::new()
    try {
        $udpClient.EnableBroadcast = $true
        $udpClient.Connect($BroadcastAddress, $Port)
        [void]$udpClient.Send($packet, $packet.Length)
    }
    finally {
        $udpClient.Close()
    }
}

Write-Host "$(Get-Date -Format T) - Checking Proxmox server status..." -ForegroundColor Cyan
if (Test-ProxmoxServerOnline -Address $ServerAddress) {
    Write-Host "$(Get-Date -Format T) - Server '$ServerAddress' is already reachable." -ForegroundColor Green
}
else {
    Write-Host "$(Get-Date -Format T) - Server '$ServerAddress' appears to be offline." -ForegroundColor Yellow
    Write-Host "$(Get-Date -Format T) - Sending Wake-on-LAN packet to $ServerMacAddress..." -ForegroundColor Cyan
    Send-ProxmoxWakeOnLan -MacAddress $ServerMacAddress -BroadcastAddress $BroadcastAddress -Port $WolPort
    Write-Host "$(Get-Date -Format T) - Magic packet sent. Waiting for the server to respond..." -ForegroundColor Cyan

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    while (-not (Test-ProxmoxServerOnline -Address $ServerAddress)) {
        if ($stopwatch.Elapsed.TotalSeconds -ge $TimeoutSeconds) {
            Write-Host "$(Get-Date -Format T) - Timed out after $TimeoutSeconds seconds waiting for the server." -ForegroundColor Red
            Write-Host "Please verify the network connection, MAC address, or Wake-on-LAN configuration." -ForegroundColor Red
            Write-Host "Press any key to exit..." -ForegroundColor DarkGray
            [void][System.Console]::ReadKey($true)
            exit 1
        }

        Start-Sleep -Seconds $RetryIntervalSeconds
        Write-Host "$(Get-Date -Format T) - Still waiting for '$ServerAddress'..." -ForegroundColor DarkYellow
    }

    $stopwatch.Stop()
    Write-Host (
        "{0} - Server is back online after {1:N0} seconds." -f (Get-Date -Format T), $stopwatch.Elapsed.TotalSeconds
    ) -ForegroundColor Green
}

Write-Host "Proxmox server '$ServerAddress' is ready for use." -ForegroundColor Green
Write-Host "Press any key to exit." -ForegroundColor Cyan
[void][System.Console]::ReadKey($true)
