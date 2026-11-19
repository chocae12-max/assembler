@echo off
setlocal
cd /d "%~dp0"

if not defined IRVINE_DIR set "IRVINE_DIR=C:\Irvine"
if not exist "%IRVINE_DIR%\Irvine32.inc" goto MissingIrvine
if not exist "%IRVINE_DIR%\Irvine32.lib" goto MissingIrvine

where ml.exe >nul 2>&1
if errorlevel 1 call :FindTools
where ml.exe >nul 2>&1
if errorlevel 1 goto MissingTools

ml.exe /nologo /c /coff /Zi /I"%IRVINE_DIR%" Arithmetic.asm
if errorlevel 1 goto BuildFailed
link.exe /nologo /SUBSYSTEM:CONSOLE /MACHINE:X86 /SAFESEH:NO /DEBUG /OUT:Arithmetic.exe /LIBPATH:"%IRVINE_DIR%" Arithmetic.obj Irvine32.lib kernel32.lib user32.lib
if errorlevel 1 goto BuildFailed
echo Built: Arithmetic.exe
exit /b 0

:FindTools
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" exit /b 1
set "VS_INSTALL="
for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VS_INSTALL=%%i"
if not defined VS_INSTALL exit /b 1
call "%VS_INSTALL%\Common7\Tools\VsDevCmd.bat" -arch=x86 -host_arch=x64
exit /b

:MissingIrvine
echo Irvine32 files were not found in "%IRVINE_DIR%".
echo Install the textbook Irvine files there, or set IRVINE_DIR.
pause
exit /b 1

:MissingTools
echo MASM was not found. Install Visual Studio Desktop development with C++.
echo Or run this file from an x86 Native Tools Command Prompt for Visual Studio.
pause
exit /b 1

:BuildFailed
echo Build failed. Check the errors above.
pause
exit /b 1
