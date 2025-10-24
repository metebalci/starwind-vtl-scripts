# defaults

$defaultAddr = [IPAddress]"127.0.0.1"
$defaultPort = 3261
$defaultUser = "root"
$defaultPass = "starwind"

$defaultTargetAlias = "mytarget"
$defaultLibraryName = "myvtl"
$defaultLibraryPath = "My Computer\C\starwind"
$defaultLibraryPatternIndex = 0

# delete files from disk
$defaultDeleteLocalCopy = $true
# delete from cloud
$defaultDeleteFromCloud = $true
# delete from offline shelf
$defaultForgetTape = $true

# constants

$STARWINDS_HEADERS_FOLDER = "C:\Program Files\StarWind Software\StarWind\headers"

# below the actual variables are set from defaults if not given by the user

if ((Test-Path variable:addr) -and ($null -eq $addr))
{
	$addr = $defaultAddr
}

if ((Test-Path variable:port) -and ($null -eq $port))
{
	$port = $defaultPort
}

if ((Test-Path variable:user) -and ($null -eq $user))
{
	$user = $defaultUser
}

if ((Test-Path variable:pass) -and ($null -eq $pass))
{
	$pass = $defaultPass
}

if ((Test-Path variable:targetAlias) -and ($null -eq $targetAlias))
{
	$targetAlias = $defaultTargetAlias	
}

if ((Test-Path variable:libraryName) -and ($null -eq $libraryName))
{
	$libraryName = $defaultLibraryName
}

if ((Test-Path variable:libraryPath) -and ($null -eq $libraryPath))
{
	$libraryPath = $defaultLibraryPath
}

if ((Test-Path variable:libraryPatternIndex) -and ($null -eq $libraryPatternIndex))
{
	$libraryPatternIndex = $defaultLibraryPatternIndex
}

if ((Test-Path variable:deleteLocalCopy) -and ($null -eq $deleteLocalCopy))
{
	$deleteLocalCopy = $defaultDeleteLocalCopy
}

if ((Test-Path variable:deleteFromCloud) -and ($null -eq $deleteFromCloud))
{
	$deleteFromCloud = $defaultDeleteFromCloud
}

if ((Test-Path variable:forgetTape) -and ($null -eq $forgetTape))
{
	$forgetTape = $defaultForgetTape
}