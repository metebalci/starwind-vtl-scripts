param($addr, $port, $user, $pass,
	$libraryName,
	$barCode,
	# tape size in megabytes
	# If this parameter is equal 0, maximum supported size by specified tape type will be used
	$size=0, 
	# part size in megabytes. Tape data files will be split into parts. 
	# If this parameter is equal 0, the tape will not split.
	$maxDataFileSize=0) 

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
	$params = new-object -ComObject StarWindX.Parameters
	if ($barcode)
	{	
		$params.AppendParam("barCode", $barCode)
	}
	$tape = $device.CreateTape($device.DriveType, $size, $maxDataFileSize, $params)
	$tape
}
finally
{
	if ($server.Connected)
	{
		$server.Disconnect()
	}
}
