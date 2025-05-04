@echo on
setlocal EnableDelayedExpansion

echo =============================================
echo PDF OCR Converter - Setup Script
echo =============================================
echo.

:: Set up paths
echo Setting up directories...
set "PROJECT_DIR=%~dp0"
cd /d "%PROJECT_DIR%"
echo Project directory: %PROJECT_DIR%

set "VENV_DIR=%PROJECT_DIR%venv"
set "TOOLS_DIR=%PROJECT_DIR%tools"
set "CONFIG_FILE=%PROJECT_DIR%config.json"

echo Virtual environment: %VENV_DIR%
echo Tools directory: %TOOLS_DIR%
echo Config file: %CONFIG_FILE%
echo.

:: Deactivate any active virtual environment
echo Deactivating any active virtual environments...
call deactivate 2>nul

:: Clean up existing directories
echo Cleaning up old directories...
taskkill /F /IM python.exe 2>nul
timeout /t 2 /nobreak >nul

echo Removing old directories...
if exist "%VENV_DIR%" (
    echo Removing existing virtual environment...
    rmdir /s /q "%VENV_DIR%" 2>nul
    if exist "%VENV_DIR%" (
        echo Failed to remove virtual environment
        echo Please close all Python processes and terminals
        echo Then try running the script again
        pause
        exit /b 1
    )
)

if exist "%TOOLS_DIR%" (
    echo Removing existing tools directory...
    rmdir /s /q "%TOOLS_DIR%" 2>nul
)

echo Creating directories...
mkdir "%TOOLS_DIR%" 2>nul
if errorlevel 1 (
    echo Failed to create tools directory
    echo Please make sure you have admin rights
    pause
    exit /b 1
)

echo Creating Python environment...
echo This may take a few moments...
python -m venv "%VENV_DIR%" --clear
if errorlevel 1 (
    echo Failed to create virtual environment
    echo Please check if Python is installed correctly
    echo And make sure you're running as administrator
    pause
    exit /b 1
)

echo.
echo Activating virtual environment...
call "%VENV_DIR%\Scripts\activate.bat" 2>nul
if errorlevel 1 (
    echo Failed to activate virtual environment
    pause
    exit /b 1
)

echo Installing Python packages...
echo Upgrading pip...
python -m pip install --upgrade pip
if errorlevel 1 (
    echo Failed to upgrade pip
    pause
    exit /b 1
)

echo Installing required packages...
python -m pip install pytesseract pdf2image
if errorlevel 1 (
    echo Failed to install Python packages
    pause
    exit /b 1
)

echo =============================================
echo Installing Dependencies
echo =============================================
echo.

echo Looking for Tesseract OCR installation...

:: First check if it's already in PATH
where tesseract >nul 2>&1
if %errorlevel% equ 0 (
    echo Found Tesseract in PATH
    goto :tesseract_ready
)

:: Check common installation locations
if exist "C:\Program Files\Tesseract-OCR\tesseract.exe" (
    set "FOUND_TESSERACT=C:\Program Files\Tesseract-OCR"
    goto :add_to_path
)

if exist "C:\Program Files (x86)\Tesseract-OCR\tesseract.exe" (
    set "FOUND_TESSERACT=C:\Program Files (x86)\Tesseract-OCR"
    goto :add_to_path
)

:: Ask user for manual path if not found
echo.
echo Tesseract not found in common locations.
echo If Tesseract is already installed, please enter the full path to its folder
echo Example: C:\Program Files\Tesseract-OCR
echo Or press Enter to open the Tesseract download page
echo.
set /p MANUAL_PATH="Enter Tesseract path (or press Enter to install): "

if not "%MANUAL_PATH%"=="" (
    if exist "%MANUAL_PATH%\tesseract.exe" (
        set "FOUND_TESSERACT=%MANUAL_PATH%"
        goto :add_to_path
    ) else (
        echo ERROR: tesseract.exe not found in specified path
        echo Make sure you entered the correct path
        pause
    )
)

:install_tesseract
echo.
echo Tesseract OCR not found. You need to install it:
echo.
echo 1. A download page will open in your browser
echo 2. Download the latest 64-bit installer (e.g. tesseract-ocr-w64-setup-5.3.1.20230401.exe)
echo 3. Run the installer
echo.
echo Press any key to open the download page...
pause >nul
start https://github.com/UB-Mannheim/tesseract/wiki
echo.
echo After installing Tesseract, press any key to continue...
pause >nul

:: Check again after installation
if exist "C:\Program Files\Tesseract-OCR\tesseract.exe" (
    set "FOUND_TESSERACT=C:\Program Files\Tesseract-OCR"
    goto :add_to_path
)

if exist "C:\Program Files (x86)\Tesseract-OCR\tesseract.exe" (
    set "FOUND_TESSERACT=C:\Program Files (x86)\Tesseract-OCR"
    goto :add_to_path
)

echo.
echo ERROR: Tesseract installation not found in common locations.
echo Please make sure you installed Tesseract correctly.
pause
exit /b 1

:add_to_path
echo.
echo Found Tesseract at: %FOUND_TESSERACT%
echo Adding Tesseract to system PATH...

echo.
echo Adding Tesseract to system PATH...
echo Location: %FOUND_TESSERACT%

:: Use PowerShell to safely set PATH
powershell -Command "& {
    $tesseractPath = '%FOUND_TESSERACT%'
    $tessdataPath = Join-Path $tesseractPath 'tessdata'
    $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'Machine')
    
    # Remove any existing Tesseract paths to avoid duplicates
    $paths = $currentPath -split ';' | Where-Object { -not $_.Contains('Tesseract-OCR') }
    $newPath = ($paths + $tesseractPath + $tessdataPath) -join ';'
    
    [Environment]::SetEnvironmentVariable('PATH', $newPath, 'Machine')
}"

:: Verify PATH update
echo.
echo Refreshing PATH and verifying installation...
set "PATH=%PATH%;%FOUND_TESSERACT%;%FOUND_TESSERACT%\tessdata"
where tesseract >nul 2>&1
if errorlevel 1 (
    echo.
    echo WARNING: Tesseract was added to PATH but might require a system restart
    echo Current location: %FOUND_TESSERACT%
    echo Please restart your computer after installation completes
    pause
) else (
    echo Tesseract successfully added to PATH
)
if errorlevel 1 (
    echo Failed to update PATH. Please add these directories manually:
    echo %FOUND_TESSERACT%
    echo %FOUND_TESSERACT%\tessdata
    pause
    exit /b 1
)

echo Successfully added Tesseract to PATH
echo NOTE: You'll need to close and reopen command windows for PATH changes to take effect

:found_tesseract
:tesseract_ready
echo.
echo Tesseract installation verified

:: Create a temporary PowerShell script for installing Poppler
set "INSTALL_SCRIPT=%TEMP%\install_deps.ps1"

:: Write PowerShell script content
echo $ErrorActionPreference = 'Stop' > "%INSTALL_SCRIPT%"
echo $ProgressPreference = 'Continue' >> "%INSTALL_SCRIPT%"
echo. >> "%INSTALL_SCRIPT%"

:: Install Poppler
echo Write-Host 'Installing Poppler...' > "%INSTALL_SCRIPT%"
echo try { >> "%INSTALL_SCRIPT%"
echo     Write-Host 'Step 1: Downloading Poppler...' >> "%INSTALL_SCRIPT%"
echo     $url = 'https://github.com/oschwartz10612/poppler-windows/releases/download/v23.07.0-0/Release-23.07.0-0.zip' >> "%INSTALL_SCRIPT%"
echo     $zip = Join-Path '%TOOLS_DIR%' 'poppler.zip' >> "%INSTALL_SCRIPT%"
echo     $popplerDir = Join-Path '%TOOLS_DIR%' 'poppler' >> "%INSTALL_SCRIPT%"
echo     Write-Host ('Downloading from: {0}' -f $url) >> "%INSTALL_SCRIPT%"
echo     [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 >> "%INSTALL_SCRIPT%"
echo     Invoke-WebRequest -Uri $url -OutFile $zip >> "%INSTALL_SCRIPT%"
echo     if (-not (Test-Path $zip)) { throw 'Failed to download Poppler' } >> "%INSTALL_SCRIPT%"
echo     Write-Host 'Download complete.' >> "%INSTALL_SCRIPT%"
echo     Write-Host 'Step 2: Preparing directories...' >> "%INSTALL_SCRIPT%"
echo     if (Test-Path $popplerDir) { Remove-Item $popplerDir -Recurse -Force } >> "%INSTALL_SCRIPT%"
echo     $binDir = Join-Path $popplerDir 'Library\bin' >> "%INSTALL_SCRIPT%"
echo     New-Item -ItemType Directory -Force -Path $binDir ^| Out-Null >> "%INSTALL_SCRIPT%"
echo     Write-Host 'Step 3: Extracting files...' >> "%INSTALL_SCRIPT%"
echo     Expand-Archive -Path $zip -DestinationPath $popplerDir -Force >> "%INSTALL_SCRIPT%"
echo     Write-Host 'Step 4: Moving files...' >> "%INSTALL_SCRIPT%"
echo     Get-ChildItem -Path $popplerDir -Recurse -File ^| Where-Object { $_.Extension -in '.exe','.dll' } ^| ForEach-Object { >> "%INSTALL_SCRIPT%"
echo         $targetPath = Join-Path $binDir $_.Name >> "%INSTALL_SCRIPT%"
echo         Write-Host ('Moving {0} to bin directory...' -f $_.Name) >> "%INSTALL_SCRIPT%"
echo         Move-Item $_.FullName $targetPath -Force >> "%INSTALL_SCRIPT%"
echo     } >> "%INSTALL_SCRIPT%"
echo     Write-Host 'Step 5: Cleaning up...' >> "%INSTALL_SCRIPT%"
echo     Remove-Item $zip -Force >> "%INSTALL_SCRIPT%"
echo     Write-Host 'Step 6: Verifying installation...' >> "%INSTALL_SCRIPT%"
echo     $pdftoppm = Get-ChildItem -Path $binDir -Filter 'pdftoppm.exe' -ErrorAction SilentlyContinue >> "%INSTALL_SCRIPT%"
echo     if (-not $pdftoppm) { throw 'Poppler installation failed: pdftoppm.exe not found' } >> "%INSTALL_SCRIPT%"
echo     Write-Host ('Found pdftoppm.exe at: {0}' -f $pdftoppm.FullName) >> "%INSTALL_SCRIPT%"
echo     Write-Host 'Step 7: Creating config file...' >> "%INSTALL_SCRIPT%"
echo     @{ poppler_path = $binDir } ^| ConvertTo-Json ^| Set-Content '%CONFIG_FILE%' >> "%INSTALL_SCRIPT%"
echo     Write-Host 'Poppler installation completed successfully!' >> "%INSTALL_SCRIPT%"
echo } catch { >> "%INSTALL_SCRIPT%"
echo     Write-Host ('Error: {0}' -f $_.Exception.Message) >> "%INSTALL_SCRIPT%"
echo     exit 1 >> "%INSTALL_SCRIPT%"
echo } >> "%INSTALL_SCRIPT%"

:: Run the PowerShell script to install Poppler
echo.
echo Installing Poppler...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%INSTALL_SCRIPT%"
if errorlevel 1 (
    echo.
    echo Failed to install Poppler. Please check the error messages above.
    pause
    exit /b 1
)

:: Verify installations
echo.
echo Verifying installations...
where tesseract >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Tesseract installation not found in PATH
    echo Please install Tesseract and make sure it's added to your PATH
    pause
    exit /b 1
)

if not exist "%TOOLS_DIR%\poppler\Library\bin\pdftoppm.exe" (
    echo.
    echo ERROR: Poppler installation not found
    echo Please check the error messages above
    pause
    exit /b 1
)

echo.
echo =============================================
echo Installation Complete!
echo =============================================
echo.
echo You can now use convert_pdf.bat to convert PDF files to text.
echo Press any key to exit...
pause > nul

if errorlevel 1 (
    echo Failed to install Poppler
    pause
    exit /b 1
)

echo.
echo Deactivating virtual environment...
deactivate

echo.
echo Setup completed successfully!
echo You can now close this window or press any key to exit...
pause > nul
exit /b 0