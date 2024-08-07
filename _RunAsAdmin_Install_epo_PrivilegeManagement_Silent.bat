CLS
@ECHO OFF
::Installs DefendPoint managed by ePO
:: written by Kevin Fason

:: Setup Shop
SET DPVERSION=23.1.264.0
IF Defined ProgramFiles(x86) (SET PROCARCH=x64) ELSE (SET PROCARCH=x86)

::Detecting ePO Presence
IF NOT EXIST "%ProgramFiles%"\McAfee\Agent\cmdagent.exe GOTO NOEPOFOUND
               
:: Detecting Admin rights
 NET SESSION >nul 2>&1  
 IF %ERRORLEVEL% EQU 0 (  
   GOTO DOSTUFFASADMIN  
   ) else (  
   GOTO NOADMINDETECTED  
   )  

:NOADMINDETECTED
 COLOR 04
 ECHO.  
 ECHO ####### WARNING: ADMINISTRATOR PRIVILEGES REQUIRED #########  
 ECHO This script must be run as a member of local administrator 
 ECHO to work properly!  
 ECHO If you're seeing this then right click on the shortcut 
 ECHO and select "Run As Administrator".
 ECHO Additionally (while holding shift) right click 
 ECHO %WINDIR%\System32\CMD.EXE ECHO then select 
 ECHO "Run As Another User" and enter a privileged account
 ECHO and run the installer again.
 ECHO ##########################################################  
 ECHO.  
 PAUSE 
 COLOR 
 EXIT /B 1 

:NOEPOFOUND
 COLOR 04
 ECHO.  
 ECHO ####### WARNING: McAfee Agent not found ########
 ECHO DefendPoint requires that McAfee Agent is present to
 ECHO Get its policy files. Please install McAfee and rerun
 ECHO This script.
 EXIT /B 1
  
:DOSTUFFASADMIN
 ECHO ####### ADMINISTRATOR PRIVILEGES DETECTED #########
 ECHO.
 ECHO This script must be run with elevation token such
 ECHO as a member of local administrator to work properly!
 ECHO.
 ECHO ####### ADMINISTRATOR PRIVILEGES DETECTED #########  
 ECHO. 
 ECHO You are running
 ECHO this script as:
 whoami
 whoami /upn
 ECHO.
 PAUSE
 ECHO.
 ECHO Installing DefendPoint in McAfee ePO mode.
 ECHO Please Wait . . .
 ECHO Upgrading DefendPoint to %DPVERSION% EPOMODE
 ECHO.
 ECHO  - Stopping DefendPoint Service
 NET STOP "Avecto DefendPoint Service"
 ECHO  - Cleaning out GPO/Web keys if they exist
 REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Avecto\Privilege Guard Client" /v "WebServerPolicyUrl" /f
 REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Avecto\Privilege Guard Client" /v "WebServerPolicyRefreshAtUserLogon" /f
 REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Avecto\Privilege Guard Client" /v "WebServerPolicyRefreshIntervalMins" /f
 REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Avecto\Privilege Guard Client" /v "WebServerCertificateDisplayName" /f
 REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Avecto\Privilege Guard Client" /v "PolicyPrecedence" /f
 REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Avecto\Privilege Guard Client" /v "WebServerPolicyUrl" /f
 REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Avecto\Privilege Guard Client" /v "WebServerPolicyRefreshAtUserLogon" /f
 REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Avecto\Privilege Guard Client" /v "WebServerPolicyRefreshIntervalMins" /f
 REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Avecto\Privilege Guard Client" /v "WebServerCertificateDisplayName" /f
 REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Avecto\Privilege Guard Client" /v "PolicyPrecedence" /f
 ECHO  - Modifying EPO keys
 REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Avecto\Privilege Guard Client" /v "ePOMode" /t REG_DWORD /d 1 /f
 REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Avecto\Privilege Guard Client" /v "PolicyEnabled" /t REG_SZ /d "EPO,LOCAL" /f
 REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Avecto\Privilege Guard Client" /v "ePOMode" /t REG_DWORD /d 1 /f
 REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Avecto\Privilege Guard Client" /v "PolicyEnabled" /t REG_SZ /d "EPO,LOCAL" /f
 ECHO  - Removing Local Policy Cache if present
 IF EXIST "%PROGRAMDATA%\Avecto\Privilege Guard\PrivilegeGuardConfig.xml" DEL "%PROGRAMDATA%\Avecto\Privilege Guard\PrivilegeGuardConfig.xml"
 IF EXIST "%PROGRAMDATA%\Avecto\Privilege Guard\Web Server Cache" RMDIR /Q /S "%PROGRAMDATA%\Avecto\Privilege Guard\Web Server Cache"
 IF EXIST "%PROGRAMDATA%\Avecto\Privilege Guard\GPO Cache" RMDIR /Q /S "%PROGRAMDATA%\Avecto\Privilege Guard\GPO Cache"
 IF EXIST "%PROGRAMDATA%\Avecto\Privilege Guard\ePO Cache" RMDIR /Q /S "%PROGRAMDATA%\Avecto\Privilege Guard\ePO Cache"

 ECHO  - Presetting Windows UAC
 REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 5 /f
 REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableInstallerDetection" /t REG_DWORD /d 1 /f
 REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 1 /f
 
 ECHO.
 ECHO - Installing %PROCESSOR_ARCHITECTURE% DefendPoint %DPVERSION% via wizard with EPOMODE=1
 ECHO --- If conflicting programs are open and you are asked, select Ignore ---
 msiexec.exe /i "%~dp0PrivilegeManagementForWindows_%PROCARCH%.msi" EPOMODE=1 APPEVENTLOGTYPE=1 /qn REBOOT=R ALLUSERS=1
 ECHO Exit code = %ERRORLEVEL%
 ECHO. 
 ECHO Waiting 10 seconds
 PING -n 11 localhost > NUL
 ECHO.
 ECHO Forcing McAfee ePO collect/send props
 "%ProgramFiles%"\McAfee\Agent\cmdagent.exe -p
 ECHO.
 ECHO Installation Complete. Restart required
 PAUSE
 GOTO END

:END