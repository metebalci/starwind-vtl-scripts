param($addr, $port, $user, $pass,
	$libraryName,
	[switch]$showEmpty)

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
	if( !$device )
	{
		throw "library not found"
	}
	if ($showEmpty)
	{
		$device.Slots | Format-Table -AutoSize -Property Barcode, slotAddress, SlotName
	}
	else 
	{
		$device.Slots | Where-Object { $_.Barcode } | Format-Table -AutoSize -Property Barcode, slotAddress, SlotName
	}
}
finally
{
	if ($server.Connected)
	{
		$server.Disconnect()
	}
}
