@echo off & setlocal enabledelayedexpansion
rem script to query jboss datasources
rem author xitiz bhatia (xitizbhatia@gmail.com)
rem version 1.5
rem NOTE: Set the value of these local variables
rem NOTE: If the password contains & then prefix it with three ^ i.e. ^^^ and don't remove double quotes around it below

set JBOSS_HOME=C:\java\jboss
set JBOSS_MANAGEMENT_IP=10.1.2.3
set JBOSS_MANAGEMENT_PORT=9999
set JBOSS_USER=username
set "JBOSS_PASSWORD=pass^^^&word"
set LOG_FILE=C:\java\jboss\scripts\data-source-report.csv

rem NOTE: DO NOT CHANGE ANYTHING BELOW THIS

SET NOPAUSE=true & set str=
set JBOSS_AUTH_STR=
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

rem setting up jboss auth
if NOT "!JBOSS_USER!x" == "x" (
  if NOT "%JBOSS_PASSWORD%x" == "x" (
     set JBOSS_AUTH_STR=--user=%JBOSS_USER%^ --password=!JBOSS_PASSWORD!
  ) else (
     set JBOSS_AUTH_STR=
  )  
) else (
set JBOSS_AUTH_STR=
)

rem now getting datasource statistics
for %%G in (CONFIG_DS VT_DS EVENT_DS SECURITY_DS QRTZ_DS OVS_DS ATCH_DS) DO (
(
set CURRENT_DATASOURCE=%%G
set str=%%G^,%mydate%_%mytime%
set VALID_OUTPUT=

for /f usebackq^ tokens^=2^,4^ delims^=^" %%A in (`"%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%JBOSS_MANAGEMENT_IP%:%JBOSS_MANAGEMENT_PORT% !JBOSS_AUTH_STR! /subsystem=datasources/data-source=!CURRENT_DATASOURCE!/statistics=pool:read-resource(recursive=true,include-runtime=true)"`) do (
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
if NOT "!str!x" == "x" echo !str! >> %LOG_FILE% 2>&1
)