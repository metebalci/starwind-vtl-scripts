param($addr, $port, $user, $pass,
	$libraryName, 
	[parameter(Mandatory=$true)]$barCode,
	[switch]$disable)

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
	foreach ($tape in $device.Tapes)
	{
		if ($tape.barCode -eq $barCode)
		{
			if ($disable)
			{
				$device.WriteProtectTape($barCode, $false)
			}
			else 
			{
				$device.WriteProtectTape($barCode, $true)
			}
			return
		}
	}
	throw "tape not found"
}
finally
{
	if ($server.Connected)
	{
		$server.Disconnect()
	}
}
