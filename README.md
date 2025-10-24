***THIS IS A WORK IN PROGRESS, IT IS NOT COMPLETED YET.***

# starwind-vtl-scripts

I have written the scripts in this repo, based on the official StarWind VTL sample scripts and discussions in the official forum. They are a bit improved, a bit simplified and a bit adapted to my way of working.

StarWind VTL Free edition has no GUI management functionality, so the scripts are a must. I am using StarWind VTL Free edition, I do not know if the scripts can be used in VTL paid edition or in other products like VSAN.

`Device` in StarWind VTL terminology is called `Library` in this repo.

## Requirements

- Install StarWind VTL Free edition. I am using it on Windows Server 2022 Standard Edition.
- Clone this repo.
- Check `defaults.ps1` in the repo and modify if needed. See the defaults section below for more info.
- Run StarWind Software/StarWindX Powershell.
- Change directory to the cloned repo folder and you can execute the scripts there.

## Scripts

The scripts can be grouped into a few categories. Their purpose is usually clear from their name.

- list (Patterns, Targets, Libraries, Tapes, Slots)
- show (Target, Library, Tape)
- create/delete (Target, Library, Tape)
- insert/eject (Tape): to VTL
- writeProtect (Tape)
- configureLibraryReplication
- download/upload (Tape): from/to Cloud
- membersOf (Server, Target, Library, Tape, Slot): outputs Get-Member for the object, useful for development, not much for normal use

## Defaults

All scripts source `defaults.ps1` which contains the default values of the parameters of the scripts and a constant. If you need and/or want, you can modify these here so you do not need to supply these everytime.

Check that server connection parameters are correct:

```
$defaultAddr = [IPAddress]"127.0.0.1"
$defaultPort = 3261
$defaultUser = "root"
$defaultPass = "starwind"
```

It is important that this variable points to the correct path: 

```
$STARWINDS_HEADERS_FOLDER = "C:\Program Files\StarWind Software\StarWind\headers"
```

The Tape files (thus the data) will be stored under this path given by this variable (starwind folder in drive C):

```
$defaultLibraryPath = "My Computer\C\starwind"
```

modify it properly if you want.

The default target is named `mytarget` and the library is named `myvtl`.

```
$defaultTargetAlias = "mytarget"
$defaultLibraryName = "myvtl"
```

When creating the library, its type is set by the pattern index:

```
$defaultLibraryPatternIndex = 0
```

this means the library will be created having 0th pattern (first pattern) type. The patterns can be seen with `./listPatterns.ps1` which at the moment outputs this:

```
HP_MSL8096_LTO8
IBM_TS03584_LTO7
```

thus, by default, the library will be HP_MSL8096_LTO8.

For `deleteTape` (including `-alsoTapes` switch of `deleteAll` and `deleteLibrary`), the following defaults are used.

```
# delete files from disk
$defaultDeleteLocalCopy = $true
# delete from cloud
$defaultDeleteFromCloud = $true
# delete from offline shelf
$defaultForgetTape = $true
```

## Configure Library Replication

StarWind VTL can upload/download the tape files to cloud storage providers. This is configured at library level. The configuration is applied to the library using `configureLibraryReplication.ps1` script. This script uses both `default.ps1` and also `configureLibraryReplicationLocalSettings.ps1`. Because replication configuration contains sensitive material like account keys, `configureLibraryReplicationLocalSettings.ps1` file is not stored in the repo. Instead, a template file `configureLibraryReplicationLocalSettings.s3.ps1` is provided. You should copy/rename this file as `configureLibraryReplicationLocalSettings.ps1` and modify the parameters inside. Then, running `configureLibraryReplication.ps1` will apply the configuration.

```
.\configureLibraryReplication.ps1

Target             : 2
AccessKey          :
SecretAccessKey    :
RegionName         :
ContainerName      :
KeepLocal          : -1
KeepInCloud        : -1
KeepInStorage1     : -1
KeepInStorage2     : 1
DelayBeforeStart   : 0
ServiceUrl         :
CreateTapeOnExport : False
```

# LICENSE

Copyright (C) 2026 Mete Balci

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.