param($addr, $port, $user, $pass,
	$libraryName,
	[switch]$showKeys)

. "$PSScriptRoot\defaults.ps1"

Import-Module StarWindX

try
{
    Enable-SWXLog
	$server = New-SWServer -host $addr -port $port -user $user -password $pass
	$server.Connect()
	if (!$server.Connected)
	{
		throw "cannot connect to the server"
	}
	$device = Get-Device $server -name $libraryName
	if (!$device)
	{
		throw "library not found"
	}
	if ($showKeys)
	{
		$device.ReplicationSettings
	}
	else
	{
		$device.ReplicationSettings | Select-Object * -ExcludeProperty AccessKey, SecretAccessKey
	}
}
finally
{
	if ($server.Connected)
	{
		$server.Disconnect()
	}
}
