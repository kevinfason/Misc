CLS
@ECHO OFF
::Installs DefendPoint managed by ePO
:: written by Kevin Fason

SET DPVERSION=23.1.264.0

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
 ECHO ##########################################################  
 ECHO.  
 PAUSE 
 COLOR 
 EXIT /B 1  

:DOSTUFFASADMIN
 ECHO ####### ADMINISTRATOR PRIVILEGES DETECTED #########
 ECHO.
 ECHO This script must be run as a member of local  
 ECHO administrator to work properly!  
 ECHO You can login as a local admin account or (while
 ECHO holding shift) right click %WINDIR%\System32\CMD.EXE 
 ECHO and select "Run As Another User". You are running
 ECHO this script as:
 whoami
 whoami /upn
 ECHO.
 PAUSE
 ECHO.
 ECHO Uninstalling existing DefendPoint %DPVERSION% in GPO/Web mode.
 ECHO  - You cannot change an install from GPO/WEB to EPO. It must be 
 ECHO    Reinstalled with correct switch
  ECHO  - Please Wait . . .
 MsiExec.exe /X{1db1ed6c-2c9d-4a45-beb5-cceed1e42040} /qn /norestart
 ECHO - Exit code = %ERRORLEVEL%
 ECHO.
 ECHO - Executing Install DefendPoint %DPVERSION% script 
 ECHO - Waiting 10 seconds
 PING -n 11 localhost > NUL
 %~dp0_RunAsAdmin_Install_epo_DefendPoint_Silent.bat
 GOTO END

:END