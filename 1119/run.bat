@echo off
setlocal
cd /d "%~dp0"
if exist Arithmetic.exe goto RunProgram
call build.bat
if errorlevel 1 exit /b 1
:RunProgram
Arithmetic.exe
if errorlevel 1 pause
