@echo off
setlocal
title baked. skate cache clearing tool
echo.
echo  baked. skate cache clearing tool
echo.
echo  Good to know: the ReSkate launcher already clears this cache by itself
echo  whenever your mod list changes, so you don't need this after adding or
echo  removing mods. Use it when the game crashes, looks wrong or stutters
echo  and nothing about your mods has changed.
echo.

rem Files in use can't be deleted, so the game has to be closed first.
tasklist /FI "IMAGENAME eq Skate.exe" 2>nul | findstr /I "Skate.exe" >nul && (
    echo skate. is running. Close the game, then run this again.
    goto :end
)

rem Total bytes of the files under %target%; PowerShell because batch math overflows past 2 GB.
set "measure=[long](Get-ChildItem -LiteralPath $env:target -Recurse -Force -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum"

set "found=0"
rem ReSkate's copy of the game's shader cache, then the plain skate. one.
call :clear "%LOCALAPPDATA%\ReSkate\Game\Skate\cache"
call :clear "%LOCALAPPDATA%\Skate\cache"
if "%found%"=="0" echo No skate. cache found on this PC. Nothing to clear.

:end
echo.
echo Thanks for using the baked. skate cache clearing tool!
echo Join us on Discord: https://discord.bakedskate.org
echo.
pause
exit /b

:clear
if not exist "%~1\" exit /b
set "found=1"
set "target=%~1"
echo Found a skate. cache at:
echo   "%~1"
choice /C YN /M "Is this the right folder"
if errorlevel 2 (echo Skipped. & echo. & exit /b)
choice /C YN /M "Delete everything in it"
if errorlevel 2 (echo Skipped. & echo. & exit /b)
for /f %%B in ('powershell -NoProfile -Command "%measure%"') do set "before=%%B"
rem Empty the folder but keep it, like the ReSkate launcher does.
del /F /S /Q "%~1\*" >nul 2>&1
for /D %%S in ("%~1\*") do rd /S /Q "%%S" 2>nul
for /f "usebackq delims=" %%M in (`powershell -NoProfile -Command "$b = %before% - (%measure%); if ($b -ge 1GB) { '{0:N2} GB' -f ($b / 1GB) } elseif ($b -ge 1MB) { '{0:N1} MB' -f ($b / 1MB) } else { '{0:N0} KB' -f ($b / 1KB) }"`) do echo Removed %%M.
dir /A /B "%~1" 2>nul | findstr "^" >nul && (
    echo Some files could not be removed. Close the game and launcher, then try again.
) || (
    echo Cache cleared. The game rebuilds it next launch, so the first load may be slower.
)
echo.
exit /b
