param($addr, $port, $user, $pass,
	$libraryName,
	$slotAddress,
	$barCode)

. "$PSScriptRoot\defaults.ps1"

Import-Module StarWindX

try
{
	if (($null -eq $slotAddress) -and ($null -eq $barCode))
	{
		throw "provide either slotAddress or barCode"
	}
	if (($null -ne $slotAddress) -and ($null -ne $barCode))
	{
		throw "provide either slotAddress or barCode"
	}
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
	if ($slotAddress)
	{
		foreach ($slot in $device.Slots)
		{
			if ($slot.slotAddress -eq $slotAddress)
			{
				$device.RemoveTape($slotAddress);
				return
			}
		}
		throw "invalid slotAddress"
	}
	elseif ($barCode)
	{
		foreach ($slot in $device.Slots)
		{
			if ($slot.Barcode -eq $barCode)
			{
				$device.RemoveTape($slot.slotAddress)
				return
			}
		}
		throw "invalid barCode"
	}
	else 
	{
		throw "either slotAddress or barCode should be supplied"
	}
}
finally
{
	if ($server.Connected)
	{
		$server.Disconnect()
	}
}
