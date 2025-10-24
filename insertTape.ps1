param($addr, $port, $user, $pass,
	$libraryName,
	$slotAddress,
	[parameter(Mandatory=$true)]$barCode)

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
	if ($slotAddress)
	{
		$device.InsertTape($barCode, $slotAddress)		
	}
	else
	{
		$inserted = $false
		foreach ($slot in $device.Slots)
		{
			if ($slot.SlotType -eq "Storage")
			{
				if (!$slot.barcode)
				{
					$device.InsertTape($barCode, $slot.slotAddress)
					$inserted = $true
					break
				}
			}
		}
		if (!$inserted)
		{
			throw "no available slot found"
		}
	}
	foreach ($slot in $device.Slots)
	{
		if ($slot.barcode -eq $barCode)
		{
			$slot
			return
		}
	}
}
finally
{
	if ($server.Connected)
	{
		$server.Disconnect()
	}
}
