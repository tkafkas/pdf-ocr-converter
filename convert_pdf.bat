@echo off
setlocal EnableDelayedExpansion

:: Set up paths
set "PROJECT_DIR=%~dp0"
cd /d "%PROJECT_DIR%"

set "VENV_DIR=%PROJECT_DIR%venv"
set "TOOLS_DIR=%PROJECT_DIR%tools"
set "POPPLER_DIR=%TOOLS_DIR%\poppler"
set "POPPLER_BIN=%POPPLER_DIR%\Library\bin"
set "CONFIG_FILE=%PROJECT_DIR%config.json"

echo PDF OCR Converter
echo ================

:: Check for PDF file
if "%~1"=="" (
    echo Please drag and drop a PDF file onto this batch file
    pause
    exit /b 1
)

echo Checking dependencies...
echo.

echo 1. Checking directories...
echo Project directory: %PROJECT_DIR%
echo Virtual environment: %VENV_DIR%
echo Tools directory: %TOOLS_DIR%
echo Poppler directory: %POPPLER_DIR%
echo Poppler bin: %POPPLER_BIN%
echo.

:: Check virtual environment
if not exist "%VENV_DIR%\Scripts\activate.bat" (
    echo Error: Virtual environment not found
    echo Please run setup.bat as administrator first
    pause
    exit /b 1
)

:: Check Poppler
if not exist "%POPPLER_BIN%\pdftoppm.exe" (
    echo Error: Poppler not found at: %POPPLER_BIN%
    echo Please run setup.bat as administrator first
    pause
    exit /b 1
)

:: Check config file
if not exist "%CONFIG_FILE%" (
    echo Error: Config file not found at: %CONFIG_FILE%
    echo Please run setup.bat as administrator first
    pause
    exit /b 1
)

echo 2. Checking config...
type "%CONFIG_FILE%"
echo.

echo 3. Testing Poppler...
"%POPPLER_BIN%\pdftoppm.exe" -v
if %errorlevel% neq 0 (
    echo Error: Poppler test failed
    pause
    exit /b 1
)
echo.

:: Activate virtual environment
call "%VENV_DIR%\Scripts\activate.bat"

echo Processing PDF: %~1
echo Output will be in the 'output' folder next to your PDF
echo.

:: Process the PDF
python pdf_to_text.py "%~1"

:: Deactivate virtual environment
deactivate

echo.
echo Conversion complete!
pause