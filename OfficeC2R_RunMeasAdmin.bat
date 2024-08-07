@ECHO OFF
CLS
TITLE Office365 ProPlus (2016) Installer
ECHO Welcome to Kevins simple Office365 (2016) Installer
ECHO.
ECHO.
ECHO Please choose the Channel
ECHO   NOTE: Semi-Annual is the channel used primarily in production
ECHO.
ECHO    1 - Semi-Annual Channel Channel
ECHO    2 - Semi-Annual Channel (Targeted)
ECHO    3 - Monthly Channel
ECHO    4 - Monthly Targeted Channel
ECHO    5 - Uninstall Office
ECHO    6 - Enable Visio and Project


SET /P M=Type 1, 2, 3, 4, or 5 then press ENTER:
ECHO.
IF %M%==1 GOTO BROAD
IF %M%==2 GOTO TARGETED
IF %M%==3 GOTO MONTHLY
IF %M%==4 GOTO INSIDERS
IF %M%==5 GOTO UNINSTALL
IF %M%==5 GOTO VISIOPROJECT

:BROAD
ECHO Installing Semi-Annual Channel, please wait . . .
"%~dp0Setup.exe" /configure "%~dp0Broad.xml"
goto END

:TARGETED
ECHO Installing Semi-Annual Channel (Targeted), please wait . . .
%~dp0Setup.exe /configure %~dp0Targeted.xml
goto END

:MONTHLY
ECHO Installing First Release for Current Channel, please wait . . .
%~dp0Setup.exe /configure %~dp0Monthly.xml
goto END

:INSIDERS
ECHO Installing Monthly Channel (Targeted) aka Insiders, please wait . . .
"%~dp0Setup.exe" /configure "%~dp0Insiders.xml"
goto END

:UNINSTALL
ECHO Uninstalling Office, please wait . . .
%~dp0setup.exe /configure %~dp0Un365x32.xml
goto END

:VISIOPROJECT
ECHO Installing Visio and Project, please wait . . .
%~dp0Setup.exe /configure %~dp0VisioProject.xml
goto END

:END
ECHO.
ECHO Done.


