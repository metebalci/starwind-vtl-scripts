param($addr, $port, $user, $pass,
	$libraryName,
	$target, $accessKey, $secretAccessKey, $regionName, $containerName, $serviceUrl,
	# -1 never delete local copy, 0 delete immediatelly after upload, N delete after N days
	$keepLocal=0,
	# -1 never delete from cloud, N>0 delete after N days
	$keepInCloud=-1,
	#S3 move to glacier interval, AZure move to cool interval in days (-1 never)
	$keepInStorage1=-1,
	#Azure only, move from cool to archieve interval in days (-1 never)
	$keepInStorage2=-1,
	# -1 never upload to cloud, 0 upload immediate after export, N>0 after N days
	$delayBeforeStart=0,
	# create new tape on export: 1-Yes, 0-No
	$createTapeOnExport=$false)

. "$PSScriptRoot\defaults.ps1"
. "$PSScriptRoot\setLibraryReplicationSettingsLocal.ps1"

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
	$settings = new-object -ComObject StarWindX.VTLReplicationSettings
	$settings.Target=[StarWindVtlReplicationTarget]$target
	$settings.AccessKey=$accessKey
	$settings.SecretAccessKey=$secretAccessKey
	$settings.RegionName=$regionName
	$settings.ContainerName=$containerName
	$settings.KeepLocal=$keepLocal
	$settings.KeepInCloud=$keepInCloud
	$settings.KeepInStorage1=$keepInStorage1
	$settings.KeepInStorage2=$keepInStorage2
	$settings.DelayBeforeStart=$delayBeforeStart
	$settings.ServiceUrl=[string]$serviceUrl
	$settings.CreateTapeOnExport=[bool]$createTapeOnExport
	$res = $device.CheckReplicationCredentials($settings)
	if ($res -ne 0)
	{
		throw "Error when checking replication credentials: " + $res
	}
	$res = $device.ApplyReplicationSettings($settings)
	if ($res -ne 0)
	{
		throw "Error when applying replication settings: " + $res
	}
	$device.ReplicationSettings | Select-Object * -ExcludeProperty AccessKey, SecretAccessKey
}
finally
{
	if ($server.Connected)
	{
		$server.Disconnect()
	}
}
