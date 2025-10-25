# starwind-vtl-scripts

I have written the scripts in this repo, based on the official StarWind VTL sample scripts and discussions in the official forum. They are a bit improved, a bit simplified and a bit adapted to my preferred way of working.

StarWind VTL Free edition has no GUI management functionality, so the scripts are a must. I do not know if the scripts can be used in VTL paid edition or in other products like VSAN. I have tried them with StarWind VTL Free on Windows Server 2022 Standard.

## VTL and Object Model

A virtual tape library (VTL) works exactly as hardware but the tapes are stored as files on the disks rather than using the tape medium. However, the terminology is still the same.

The objects in StarWind VTL are:

- Server: the StarWind VTL (Free) server
- Target: iSCSI target
- Device: Virtual Tape Library (VTL) device
- Slot: A slot in VTL
- Tape: Virtual Tape used by a VTL device

I call `Device` in StarWind VTL `Library` in this repo.

Thus, the object model is:

- There is one server e.g. VTL Free
- Server has Targets and Devices (Libraries). I think they can exist independent of each other but to be used a Device (Library) has to be attached to a Target.
- A Target has zero or more attached Devices (Libraries). Thus, by accessing iSCSI target externally, one can use VTL.
- A Device (Library) has slots. The number of slots are not configurable, it is fixed based on the selected device type.
- A Device has zero or more Tapes. These tapes can be inserted into the slots of a device or they can be kept at the offline shelf.

Additionally, the Tapes on the offline shelf can be uploaded/downloaded from the Cloud, this is called Replication.

## Requirements

- Install StarWind VTL Free edition. I am using it on Windows Server 2022 Standard Edition.
- Clone this repo.
- Check `defaults.ps1` in the repo and modify if needed. See the Defaults section below for more info. Also check Configure Library Replication section below to configure the settings for replication.
- Run StarWind Software/StarWindX Powershell.
- Change directory to the cloned repo folder and you can execute the scripts there.

## Scripts

The scripts can be grouped into a few categories. Their purpose is usually clear from their name.

- list (Patterns, Targets, Libraries, Tapes, Slots)
- show (Target, Library, Tape)
- create/delete (Target, Library, Tape)
- (insert/eject) Tape: to VTL
- writeProtectTape
- (get/set) LibraryReplicationSettings
- download/upload (Tape): from/to Cloud
- membersOf (Server, Target, Library, Tape, Slot): outputs Get-Member for the object, useful for development

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

## Tutorial

```
This tutorial assumes a clean VTL Free installation and it will use the defaults. If you already have mytarget and myvtl, you should delete them first.
```

Before doing anything, lets see which patterns are available. A pattern is basically a library type.

```
.\listPatterns.ps1
HP_MSL8096_LTO8
IBM_TS03584_LTO7
```

Because the default value of `libraryPatternIndex` is 0, in this tutorial, we will be creating a library of type HP_MSL8096_LTO8. This is a 96 slot (virtual) tape library with four tape drives. I think it is originally only for LTO-3 and LTO-4 but in this virtual configuration it consists of LTO-8 drives (12TB uncompressed capacity).

First, lets create a target (default target=`mytarget`). If the operation is successful, it shows the detailed information (same as show script output) about the created target.

```
.\createTarget.ps1

Name        : iqn.2008-08.com.starwindsoftware:vtl-mytarget
Id          : 0x0000013691AC7D80
Alias       : mytarget
IsClustered : True
Devices     : System.__ComObject
Permissions : System.__ComObject
type
```

You can view all the targets with the list script.

```
.\listTargets.ps1

Alias    Name
-----    ----
mytarget iqn.2008-08.com.starwindsoftware:vtl-mytarget
```

Now, lets create a library (default library=`myvtl`). If the operation is successful, it shows the detailed information (same as show script output) about the created library.

A library can be created independent of a target but to use it, it should be attached to a target. Thus, `createLibrary.ps1` script attaches the created library to the given target (or default target=`mytarget`).

```
.\createLibrary.ps1

Name                   : myvtl
DeviceType             : VTL
DeviceId               : 0x000001369196F9C0
File                   :
TargetName             : empty
TargetId               : empty
Size                   : 0
CacheMode              : empty
CacheSize              : empty
CacheBlockExpiryPeriod : empty
Exists                 : True
DeviceLUN              :
IsSnapshotsSupported   : False
Snapshots              :
SectorSize             :
State                  : 0
Parent                 :
Tapes                  : System.__ComObject
AvailableSlots         : 96
TransportSlots         : 1
DriveSlots             : 4
ImportExportSlots      : 3
StorageSlots           : 96
Slots                  : System.__ComObject
ReplicationSettings    : System.__ComObject
DriveType              : 8
```

You can view all the libraries with the list script.

```
.\listLibraries.ps1

Name  TargetName
----  ----------
myvtl iqn.2008-08.com.starwindsoftware:vtl-mytarget
```

Now, lets create a tape. `createTape.ps1` script by default do not limit the `size` of the tape or `maxDataFileSize` of the files of a tape. Thus, there will be a single file for each tape and the maximum size of the tape depends on the tape type (drive type of the library). For LTO-8, it will be 12TB.

If the `createTape.ps1` operation is successful, it shows the detailed information (same as show script output) about the created tape.

```
.\createTape.ps1

Barcode   : SWAMM001
SlotType  : Storage
TapeType  : U-832
Size      : 12582912
UsedSpace : 0
```

As you see, the size is 12TB, the size of an LTO-8 tape.

You can use `-barCode` parameter if you want to supply your own barcode value, like this:

```
.\createTape.ps1 -barCode abc

Barcode   : abc
SlotType  : Storage
TapeType  : U-832
Size      : 12582912
UsedSpace : 0
```

You can view all the tapes of a device with the list script. It is not explicitly visible here but `listTapes.ps1` lists the tapes of a single library. The default library `myvtl` is the default value of the parameter `-libraryName`.

```
.\listTapes.ps1

Barcode  UsedPercent SizeTB Slot
-------  ----------- ------ ----
SWAMM001           0     12 1001
abc                0     12 1002
```

As you can see the size of the types are 12TB (LTO-8) and naturally they are empty (0% used).

When a tape is created, it is automatically inserted into the first empty (Storage) slot of the library. These are shown in this output under Slot column. If a tape is not inserted to a slot, the Slot column will be empty.

You can also view the slots of a library with the list script:

```
.\listSlots.ps1

Barcode  slotAddress SlotName
-------  ----------- --------
SWAMM001        1001 Storage 01
abc             1002 Storage 02
```

You can also use `-showEmpty` switch with `listSlots.ps1`, which will output all slots.

```
.\listSlots.ps1 -showEmpty

Barcode  slotAddress SlotName
-------  ----------- --------
                   0 Transport 1
                   1 TapeDrive 1
                   2 TapeDrive 2
                   3 TapeDrive 3
                   4 TapeDrive 4
                 101 ImpExp 1
                 102 ImpExp 2
                 103 ImpExp 3
SWAMM001        1001 Storage 01
abc             1002 Storage 02
                1003 Storage 03
                1004 Storage 04
                ...
                1095 Storage 95
                1096 Storage 96         
```

The current status can also be seen in the StarWind Management Console as:

![StarWind Management Console Screenshot](https://github.com/metebalci/starwind-vtl-scripts/blob/main/gui.png?raw=true)

At this point, VTL is ready to be used. Naturally, you can create as many tapes as you like.

A tape can be deleted with `deleteTape.ps1` script. However, it cannot be deleted at the moment because the tapes are in use (already inserted into a slot). Before deleting, the tape has to be ejected. Normally, a tape is ejected from a slot by giving slot address. For ease of use, `ejectTape.ps1` script can use either slot address or barcode.

```
.\ejectTape.ps1 -barCode abc
```

Now if you check slots with `listSlots.ps1`, there will be only one slot listed since the other tape (barcode=abc) is ejected:

```
.\listSlots.ps1

Barcode  slotAddress SlotName
-------  ----------- --------
SWAMM001        1001 Storage 01
```

Lets check with `listTapes.ps1`:

```
.\listTapes.ps1

Barcode  UsedPercent SizeTB Slot
-------  ----------- ------ ----
SWAMM001           0     12 1001
abc
```

Here the tape with barcode=abc has no other fields and no slot address, because it is ejected (since it is ejected, its properties cannot be known).

Now it can be deleted:

```
.\deleteTape.ps1 -barcode abc
.\listTapes.ps1

Barcode  UsedPercent SizeTB Slot
-------  ----------- ------ ----
SWAMM001           0     12 1001
```

An ejected tape can also be inserted with `insertTape.ps1` script. This requires a `-barCode` parameter and optionally `-slotAddress` parameter. If `-slotAddress` is not given, the first available storage slot is used.

In order to use the VTL, you need to know the IQN (iSCSI Qualified Name) of a target. The IQN and other information about a target can be viewed with show script:

```
.\showTarget.ps1

Name        : iqn.2008-08.com.starwindsoftware:vtl-mytarget
Id          : 0x0000013691A8C180
Alias       : mytarget
IsClustered : True
Devices     : System.__ComObject
Permissions : System.__ComObject
type        :
```

Detailed information about a library can be viewed with show script:

```
.\showLibrary.ps1

Name                   : myvtl
DeviceType             : VTL
DeviceId               : 0x0000013691974B80
File                   :
TargetName             : iqn.2008-08.com.starwindsoftware:vtl-mytarget
TargetId               : 0x0000013691A8C180
Size                   : 0
CacheMode              : empty
CacheSize              : empty
CacheBlockExpiryPeriod : empty
Exists                 : True
DeviceLUN              : 0
IsSnapshotsSupported   : False
Snapshots              :
SectorSize             :
State                  : 0
Parent                 :
Tapes                  : System.__ComObject
AvailableSlots         : 95
TransportSlots         : 1
DriveSlots             : 4
ImportExportSlots      : 3
StorageSlots           : 96
Slots                  : System.__ComObject
ReplicationSettings    : System.__ComObject
DriveType              : 8
```

You can see AvailableSlots is 95 but StorageSlots are 96, since one tape is inserted.

Detailed information about a tape can be viewed with show script. You should modify the barCode value in the example below, since the barcode of your tapes will be different as it is auto-generated.

```
.\showTape.ps1 -barCode SWAMM001

Barcode   : SWAMM001
SlotType  : Storage
TapeType  : U-832
Size      : 12582912
UsedSpace : 0
```

In order to delete the tape(s), library and target, delete scripts can be used. There is also a `deleteTape.ps1` script but to delete all tapes `deleteLibrary.ps1` can be run with `-alsoTapes` switch. If `-alsoTapes` is not used, the tape files are not removed from the system but they belong to nothing now, I am not sure how they can be re-used.

```
$ .\deleteLibrary.ps1 -alsoTapes
$ .\deleteTarget.ps1
```

## Configure Library Replication

StarWind VTL can upload/download the tape files to cloud storage providers. This is configured at library level. The configuration is applied to the library using `setLibraryReplicationSettings.ps1` script. This script uses both `default.ps1` and also `setLibraryReplicationSettingsLocal.ps1`. Because replication configuration contains sensitive material like account keys, `setLibraryReplicationSettingsLocal.ps1` file is not stored in the repo. Instead, template files `setLibraryReplicationSettingsLocal.*.ps1` are provided. You should copy/rename one of these template files as `setLibraryReplicationSettingsLocal.ps1` and modify the parameters inside. Then, running `setLibraryReplicationSettings.ps1` will apply the configuration.

```
.\setLibraryReplicationSettings.ps1

Target             : 32
RegionName         : eu-central-2
ContainerName      : myvtl
KeepLocal          : 0
KeepInCloud        : -1
KeepInStorage1     : -1
KeepInStorage2     : -1
DelayBeforeStart   : 0
ServiceUrl         : https://s3.eu-central-2.wasabisys.com
CreateTapeOnExport : False
```

The AccessKey and SecretAccessKey is not shown in the output.

The current replication setting can be viewed with `getLibraryReplicationSettings.ps1` script. If you need to view the keys, `-showKeys` switch can be used.

When the replication is configured, `uploadTape.ps1` and `downloadTape.ps1` scripts can be used. In order to be uploaded/downloaded, the tape should be on the offline shelf, it should be ejected first.

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