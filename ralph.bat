@echo off
REM Ralph Loop Launcher for Windows
REM Quick launcher for the Ralph autonomous Claude Code loop

setlocal EnableDelayedExpansion

echo.
echo =====================================
echo   RALPH LOOP - Windows Launcher
echo =====================================
echo.

REM Check if PowerShell is available
where pwsh >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set PS_CMD=pwsh
) else (
    set PS_CMD=powershell
)

REM Check for arguments
if "%~1"=="" (
    echo Usage: ralph.bat "Your prompt here" [max-iterations] [completion-promise]
    echo.
    echo Examples:
    echo   ralph.bat "Build a REST API" 50 COMPLETE
    echo   ralph.bat --file PROMPT.md 30 DONE
    echo.
    echo Options:
    echo   --file PROMPT.md    Load prompt from file
    echo   --help              Show this help
    echo.
    goto :eof
)

if "%~1"=="--help" (
    echo Ralph Loop - Autonomous Claude Code Loop for Windows
    echo.
    echo This tool runs Claude Code in an autonomous loop, allowing it to
    echo iteratively improve code until a completion promise is detected.
    echo.
    echo Based on the Ralph Wiggum technique by Geoffrey Huntley.
    echo.
    goto :eof
)

set PROMPT=%~1
set MAX_ITER=50
set PROMISE=COMPLETE

if not "%~2"=="" set MAX_ITER=%~2
if not "%~3"=="" set PROMISE=%~3

echo Starting Ralph Loop...
echo Prompt: %PROMPT%
echo Max Iterations: %MAX_ITER%
echo Completion Promise: %PROMISE%
echo.

if "%~1"=="--file" (
    %PS_CMD% -ExecutionPolicy Bypass -File "%~dp0ralph-loop.ps1" -Prompt "See PROMPT.md" -PromptFile "%~2" -MaxIterations %MAX_ITER% -CompletionPromise %PROMISE%
) else (
    %PS_CMD% -ExecutionPolicy Bypass -File "%~dp0ralph-loop.ps1" -Prompt "%PROMPT%" -MaxIterations %MAX_ITER% -CompletionPromise %PROMISE%
)

echo.
echo Ralph Loop finished.
pause
