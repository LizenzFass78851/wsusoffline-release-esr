@echo off
rem *** Author: T. Wittrock, Kiel ***
rem ***   - Community Edition -   ***

if "%OS_RAM_GB%"=="" (
  if /i "%OS_ARCH%"=="x86" (set UPDATES_PER_STAGE=60) else (set UPDATES_PER_STAGE=40)
) else (
  if /i "%OS_ARCH%"=="x86" (set /A UPDATES_PER_STAGE=OS_RAM_GB*60) else (set /A UPDATES_PER_STAGE=OS_RAM_GB*40)
)
if exist .\custom\SetUpdatesPerStage.cmd call .\custom\SetUpdatesPerStage.cmd
if %UPDATES_PER_STAGE% LSS 40 set UPDATES_PER_STAGE=40

set WUA_VER_TARGET_MAJOR=0
set WUA_VER_TARGET_MINOR=0
set WUA_VER_TARGET_BUILD=0
set WUA_VER_TARGET_REVIS=0
set WUA_TARGET_ID=

set WUA_VER_SHA2_MAJOR=0
set WUA_VER_SHA2_MINOR=0
set WUA_VER_SHA2_BUILD=0
set WUA_VER_SHA2_REVIS=0

set MSI_VER_TARGET_BUILD=0
set MSI_VER_TARGET_REVIS=0

set IE_VER_TARGET_BUILD=0
set IE_VER_TARGET_REVIS=0

set DOTNET35_VER_TARGET_MAJOR=3
set DOTNET35_VER_TARGET_MINOR=5
set DOTNET35_VER_TARGET_BUILD=30729
set DOTNET35_VER_TARGET_REVIS=1

if "%INSTALL_DOTNET4%"=="/instdotnet4" (
  if "%OS_VER_MAJOR%.%OS_VER_MINOR%.%OS_VER_BUILD_INTERNAL%"=="10.0.10240" (
    set DOTNET4_RELEASE_TARGET=394806
  ) else if "%OS_VER_MAJOR%.%OS_VER_MINOR%.%OS_VER_BUILD_INTERNAL%"=="10.0.18362" (
    set DOTNET4_RELEASE_TARGET=528040
  ) else (
    set DOTNET4_RELEASE_TARGET=528049
  )
) else (
  rem .NET Framework 4.6.2 or newer is required starting 05/2022
  if "%OS_VER_MAJOR%.%OS_VER_MINOR%.%OS_VER_BUILD_INTERNAL%"=="10.0.14393" (
    set DOTNET4_RELEASE_TARGET=394802
  ) else (
    set DOTNET4_RELEASE_TARGET=394806
  )
)

set WMF_VER_TARGET_MAJOR=5
set WMF_VER_TARGET_MINOR=1
set WMF_PREREQ_DOTNET4_RELEASE=379893

set TSC_VER_TARGET_BUILD=0
set TSC_VER_TARGET_REVIS=0

if %OS_VER_MAJOR% LSS 5 goto SetOfficeName
if %OS_VER_MAJOR% GTR 10 goto SetOfficeName
if %OS_VER_MINOR% GTR 3 goto SetOfficeName
goto Windows%OS_VER_MAJOR%.%OS_VER_MINOR%

:Windows5.0
rem *** Windows 2000 ***
set OS_NAME=w2k
goto SetOfficeName

:Windows5.1
rem *** Windows XP ***
set OS_NAME=wxp
goto SetOfficeName

:Windows5.2
rem *** Windows Server 2003 ***
set OS_NAME=w2k3
goto SetOfficeName

:Windows6.0
rem *** Windows Server 2008 ***
set OS_NAME=w60
rem "long search" issue does not really occur even running WUA 7.6.7600.256 [standalone] released 06/2012 / 07/2014 [tested using w2k8 and 07/2020 catalog]
rem SHA2-support added in WUA 7.7.6003.20705 [KB4534312/KB4534303] released 01/2020
set WUA_VER_TARGET_MAJOR=7
set WUA_VER_TARGET_MINOR=7
set WUA_VER_TARGET_BUILD=6003
set WUA_VER_TARGET_REVIS=20705
set WUA_TARGET_ID=4534312
set WUA_VER_SHA2_MAJOR=7
set WUA_VER_SHA2_MINOR=7
set WUA_VER_SHA2_BUILD=6003
set WUA_VER_SHA2_REVIS=20705
set MSI_VER_TARGET_MAJOR=4
set MSI_VER_TARGET_MINOR=5
set IE_VER_TARGET_MAJOR=9
set IE_VER_TARGET_MINOR=0
if %OS_DOMAIN_ROLE% LEQ 1 (
  set TSC_VER_TARGET_MAJOR=6
  set TSC_VER_TARGET_MINOR=1
  set TSC_TARGET_ID=969084
) else (
  set TSC_VER_TARGET_MAJOR=6
  set TSC_VER_TARGET_MINOR=0
)
set DOTNET4_PREREQ_ID=956250
set WMF_VER_TARGET_MAJOR=3
set WMF_VER_TARGET_MINOR=0
if %WMF_VER_MAJOR% LSS 2 (set WMF_TARGET_ID=968930) else (set WMF_TARGET_ID=2506146)
set WOU_ENDLESS=9
goto Windows%OS_VER_MAJOR%.%OS_VER_MINOR%.%OS_SP_VER_MAJOR%
:Windows6.0.
:Windows6.0.0
set OS_SP_VER_TARGET_MAJOR=1
set OS_SP_TARGET_ID=936330
goto SetOfficeName
:Windows6.0.1
:Windows6.0.2
set OS_SP_VER_TARGET_MAJOR=2
set OS_SP_TARGET_ID=948465
set SHA2_PREREQ_ID=4474419
goto SetOfficeName

:Windows6.1
rem *** Windows 7 / Server 2008 R2 ***
set OS_NAME=w61
set OS_SP_VER_TARGET_MAJOR=1
set OS_SP_TARGET_ID=976932
rem "long search" issue fixed in WUA 7.6.7601.19046 [KB3102810] released 11/2015 (actually works since 7.6.7601.18917 [KB3065987] released 07/2015)
rem SHA2-support added in WUA 7.6.7601.24542 [KB4534314/KB4534310] released 01/2020
set WUA_VER_TARGET_MAJOR=7
set WUA_VER_TARGET_MINOR=6
set WUA_VER_TARGET_BUILD=7601
set WUA_VER_TARGET_REVIS=24542
set WUA_TARGET_ID=4534314
set WUA_VER_SHA2_MAJOR=7
set WUA_VER_SHA2_MINOR=6
set WUA_VER_SHA2_BUILD=7601
set WUA_VER_SHA2_REVIS=24542
set MSI_VER_TARGET_MAJOR=5
set MSI_VER_TARGET_MINOR=0
set IE_VER_TARGET_MAJOR=9
set IE_VER_TARGET_MINOR=11
set WMF_TARGET_ID=3191566
set TSC_VER_TARGET_MAJOR=6
set TSC_VER_TARGET_MINOR=3
set TSC_TARGET_ID_FILE=..\static\StaticUpdateIds-rdc-w61.txt
set SHA2_PREREQ_ID=4474419
set WOU_ENDLESS=9
goto SetOfficeName

:Windows6.2
rem *** Windows Server 2012 ***
set OS_NAME=w62
set OS_SP_VER_TARGET_MAJOR=0
rem "long search" issue fixed in WUA 7.8.9200.22695 [KB4493451] released 04/2019
set WUA_VER_TARGET_MAJOR=7
set WUA_VER_TARGET_MINOR=8
set WUA_VER_TARGET_BUILD=9200
set WUA_VER_TARGET_REVIS=22695
rem using 04/2020 SecOnly [KB4550971] as update for WUA
set WUA_TARGET_ID=4550971
set WUA_VER_SHA2_MAJOR=7
set WUA_VER_SHA2_MINOR=9
set WUA_VER_SHA2_BUILD=9200
set WUA_VER_SHA2_REVIS=16384
set MSI_VER_TARGET_MAJOR=5
set MSI_VER_TARGET_MINOR=0
set IE_VER_TARGET_MAJOR=9
set IE_VER_TARGET_MINOR=11
set WMF_TARGET_ID=3191565
set TSC_VER_TARGET_MAJOR=6
set TSC_VER_TARGET_MINOR=2
set WOU_ENDLESS=6
goto SetOfficeName

:Windows6.3
rem *** Windows 8.1 / Server 2012 R2 ***
set OS_NAME=w63
set OS_SP_VER_TARGET_MAJOR=0
set OS_SP_PREREQ_ID=2975061
set OS_SP_TARGET_ID=2919355
set OS_UPD1_TARGET_REVIS=17041
set OS_UPD2_TARGET_REVIS=17415
rem "long search" issue fixed in WUA 7.9.9600.18094 [KB3102812] released 11/2015
set WUA_VER_TARGET_MAJOR=7
set WUA_VER_TARGET_MINOR=9
set WUA_VER_TARGET_BUILD=9600
set WUA_VER_TARGET_REVIS=18094
set WUA_TARGET_ID=3102812
rem set WUA_TARGET_ID=3112336
rem set WUA_TARGET_ID=3135449
rem set WUA_TARGET_ID=3138615
rem set WUA_TARGET_ID=3172614
set WUA_VER_SHA2_MAJOR=7
set WUA_VER_SHA2_MINOR=9
set WUA_VER_SHA2_BUILD=9600
set WUA_VER_SHA2_REVIS=16384
set MSI_VER_TARGET_MAJOR=5
set MSI_VER_TARGET_MINOR=0
set IE_VER_TARGET_MAJOR=9
set IE_VER_TARGET_MINOR=11
set WMF_TARGET_ID=3191564
set TSC_VER_TARGET_MAJOR=6
set TSC_VER_TARGET_MINOR=3
set WOU_ENDLESS=6
goto SetOfficeName

:Windows10.0
if %OS_VER_BUILD% GEQ 20231 goto Windows11.0
rem *** Windows 10.0 / Server 2016/2019 ***
set OS_NAME=w100
set OS_SP_VER_TARGET_MAJOR=0
set WUA_VER_TARGET_MAJOR=10
set WUA_VER_SHA2_MAJOR=10
set MSI_VER_TARGET_MAJOR=5
set MSI_VER_TARGET_MINOR=0
set IE_VER_TARGET_MAJOR=9
set IE_VER_TARGET_MINOR=11
set TSC_VER_TARGET_MAJOR=10
set TSC_VER_TARGET_MINOR=0
set WOU_ENDLESS=3
goto SetOfficeName

:Windows11.0
rem *** Windows 11 / Server xxx ***
set OS_NAME=w110
goto SetOfficeName

:SetOfficeName
set OFC_INSTALLED=0
if "%O2K13_VER_MAJOR%"=="" goto NoO2k13
rem *** Office 2013 ***
set OFC_INSTALLED=1
set O2K13_SP_VER_TARGET=1
set O2K13_SP_TARGET_ID=2817430-fullfile-%O2K13_ARCH%
:NoO2k13
if "%O2K16_VER_MAJOR%"=="" goto NoO2k16
rem *** Office 2016 ***
set OFC_INSTALLED=1
set O2K16_SP_VER_TARGET=0
:NoO2k16
goto EoF

:EoF
