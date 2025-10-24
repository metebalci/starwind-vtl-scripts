param($addr, $port, $user, $pass,
	$libraryName,
	[parameter(Mandatory=$true)]$barCode,
	$deleteLocalCopy,
	$deleteFromCloud,
	$forgetTape)

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
	$device.DeleteTape($barCode, $deleteLocalCopy, $deleteFromCloud, $forgetTape)
}
finally
{
	if ($server.Connected)
	{
		$server.Disconnect()
	}
}
