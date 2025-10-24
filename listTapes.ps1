param($addr="127.0.0.1", $port=3261, $user="root", $password="starwind",
	$libraryName='myvtl')

Import-Module StarWindX

try
{
	Enable-SWXLog
	$server = New-SWServer $addr $port $user $password
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
	$tapes = @()
	foreach ($tape in $device.Tapes) 
	{
		$slotAddress = $null
		foreach ($slot in $device.Slots)
		{
			if ($slot.Barcode -eq $tape.Barcode)
			{
				$slotAddress = $slot.slotAddress
				break
			}
		}
		$tapes += [PSCustomObject]@{
			Barcode = $tape.Barcode;
			UsedSpace = $tape.UsedSpace;
			Size = $tape.Size;
			Slot = $slotAddress}
	}
	$tapes | Format-Table -AutoSize Barcode, 
	@{
		Name='UsedPercent'
		Expression={ if ($_.Size -ne 0) { [math]::round(($_.UsedSpace * 100) / $_.Size, 1) } else { ' ' } }
		Align='Right'
	}, 
	@{
		Name='SizeTB'
		Expression={ if ($_.Size -ne 0) { [math]::round($_.Size / 1MB, 1) } else { ' ' } }
		Align='Right'
	}, 
	@{
		Name='Slot'
		Expression={ if ($_.Slot) { $_.Slot } else { '' } }
		Align='Right'
	}
}
finally
{
	if ($server.Connected)
	{
		$server.Disconnect()
	}
}
