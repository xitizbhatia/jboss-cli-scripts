@echo off & setlocal enabledelayedexpansion
rem script to query jboss datasources
rem author xitiz bhatia (xitizbhatia@gmail.com)
rem version 1.4
rem NOTE: Set the value of these local variables

set JBOSS_HOME=C:\java\jboss-eap-6.4
set JBOSS_MANAGEMENT_IP=10.0.0.121
set JBOSS_MANAGEMENT_PORT=9999
set LOG_FILE=C:\java\jboss-eap-6.4\scripts\data-source-report.csv

rem NOTE: DO NOT CHANGE ANYTHING BELOW THIS

SET NOPAUSE=true & set str=
set DSNAME=DataSourceName
set ACC=ActiveCount
set AVC=AvailableCount
set ABT=AverageBlockingTime
set ACT=AverageCreationTime
set CRC=CreatedCount
set DEC=DestroyedCount
set IUC=InUseCount
set MCT=MaxCreationTime
set MUC=MaxUsedCount
set MWC=MaxWaitCount
set MWT=MaxWaitTime
set TO=TimedOut
set TBT=TotalBlockingTime
set TCT=TotalCreationTime
set CTS=CurrentTimeStamp

if not exist %LOG_FILE% (
echo %DSNAME%^,%CTS%^,%ACC%^,%AVC%^,%ABT%^,%ACT%^,%CRC%^,%DEC%^,%IUC%^,%MCT%^,%MUC%^,%MWC%^,%MWT%^,%TO%^,%TBT%^,%TCT% > %LOG_FILE%
) else (
rem File already exists. Will append to it.
)

rem getting date time
@echo off
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)

rem now getting datasource statistics
for %%G in (CONFIG_DS VT_DS EVENT_DS SECURITY_DS QRTZ_DS OVS_DS ATCH_DS) DO (
(
set CURRENT_DATASOURCE=%%G
set str=%%G^,%mydate%_%mytime%
set VALID_OUTPUT=
for /f usebackq^ tokens^=2^,4^ delims^=^" %%A in (`%JBOSS_HOME%\bin\jboss-cli.bat "connect %JBOSS_MANAGEMENT_IP%:%JBOSS_MANAGEMENT_PORT%,/subsystem=datasources/data-source=!CURRENT_DATASOURCE!/statistics=pool:read-resource(recursive=true,include-runtime=true),exit"`) do (
    if "%%B" == "success" (
      set VALID_OUTPUT="Y"
    ) else (
      rem do nothing
    )

    rem echo %%G %%A %%B
    if !VALID_OUTPUT! == "Y" (
      if "%%A"=="%ACC%" (set str=!str!^,%%B)
      if "%%A"=="%AVC%" (set str=!str!^,%%B)
      if "%%A"=="%ABT%" (set str=!str!^,%%B)
      if "%%A"=="%ACT%" (set str=!str!^,%%B)
      if "%%A"=="%CRC%" (set str=!str!^,%%B)
      if "%%A"=="%DEC%" (set str=!str!^,%%B)
      if "%%A"=="%IUC%" (set str=!str!^,%%B)
      if "%%A"=="%MCT%" (set str=!str!^,%%B)
      if "%%A"=="%MUC%" (set str=!str!^,%%B)
      if "%%A"=="%MWC%" (set str=!str!^,%%B)
      if "%%A"=="%MWT%" (set str=!str!^,%%B)
      if "%%A"=="%TO%" (set str=!str!^,%%B)
      if "%%A"=="%TBT%" (set str=!str!^,%%B)
      if "%%A"=="%TCT%" (set str=!str!^,%%B)
    ) else (
      set "str="
    )
   )
)
if NOT "!str!x" == "x" echo !str! >> %LOG_FILE%
)