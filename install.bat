@echo on
setlocal EnableDelayedExpansion

:: Start in a new window that stays open
if not defined INSTALL_RUNNING (
    set INSTALL_RUNNING=1
    start "PDF OCR Converter Installation" /wait cmd /k "%~f0"
    exit /b
)

cls
echo ================================================
echo PDF OCR Converter - Installation Script
echo ================================================
echo.
echo This window will stay open to show the full process.
echo.
echo Press any key to start installation...
pause > nul
echo.

echo Starting installation at: %date% %time%
echo ================================================

:: Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"
echo Script directory: %SCRIPT_DIR%
echo.

:: Call setup.bat with full path
echo Running setup script...
echo.
call "%SCRIPT_DIR%setup.bat"
set SETUP_ERROR=%errorlevel%

echo.
echo ================================================
echo Installation Status
echo ================================================
if %SETUP_ERROR% == 0 (
    echo [SUCCESS] Installation completed successfully!
) else (
    echo [ERROR] Installation failed with code: %SETUP_ERROR%
    echo.
    echo Troubleshooting steps:
    echo 1. Make sure you ran this as administrator
    echo 2. Check your internet connection
    echo 3. Ensure the 'tools' folder is not in use
    echo 4. Look above for specific error messages
)

echo.
echo Installation finished at: %date% %time%
echo ================================================
echo.
echo Process completed. Window will stay open.
echo Press any key to close this window...
pause > nul