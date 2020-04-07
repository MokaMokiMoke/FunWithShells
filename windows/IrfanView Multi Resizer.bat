@echo
color f
title IrfanView Multi Resizer 
REM +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
REM maxfries@t-online.de: 08.07.2015
REM +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
setlocal
echo off
cls

echo Enter output qualit (JPG)
@set /p qual=
echo.
echo Enter Resolution numbers with spaces
@set /p liste=
echo.
echo Enter Image Directory
@set /p indir=

set rundir=%programfiles(x86)%\IrfanView
set param=/aspectratio /resample /jpgq=%qual%

color e
echo.
echo Work in progress...
echo.

for %%a in (%liste%) do (
"%rundir%\i_view32.exe" %indir%\*.* /resize_long=%%a %param% /convert=%indir%\%%a\*_%%a.jpg
)

for %%b in (%liste%) do (

for %%f in ("%indir%\%%b\*.jpg") do rename "%%f" "%%~nf_%%b.jpg" 
move "%indir%\%%b\*.jpg" "%indir%"
del "%indir%\%%b\*" /q
cd ..
rmdir "%indir%\%%b"
)

color a
cls
echo.
echo Fertig!
echo.
echo.
color f

pause

endlocal
:End
