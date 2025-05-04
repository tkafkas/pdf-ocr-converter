# PDF OCR Converter

This Python application converts image-based PDFs into searchable text PDFs using OCR (Optical Character Recognition). It preserves the original layout while adding a searchable text layer.

## Features

- Convert image-based PDFs to searchable PDFs
- Preserve original document layout and formatting
- Support for multiple languages
- Custom output filename option
- Progress tracking during conversion
- Batch processing capabilities

## Prerequisites

1. Python 3.7 or higher
2. Tesseract OCR must be installed on your system:
   - Windows: Download and install from https://github.com/UB-Mannheim/tesseract/wiki
   - Linux: `sudo apt-get install tesseract-ocr`
   - Mac: `brew install tesseract`

## Installation

### Automatic Setup (Windows)

1. Clone or download this repository
2. Run `install.bat` to set up the virtual environment:
   ```bash
   install.bat
   ```
   This script will:
   - Create a Python virtual environment
   - Install all required dependencies
   - Run the setup configuration through `setup.bat`

### Manual Setup

If you prefer manual installation:
1. Clone or download this repository
2. Create and activate a virtual environment:
   ```bash
   python -m venv venv
   venv\Scripts\activate  # On Windows
   source venv/bin/activate  # On Linux/Mac
   ```
3. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```

## Usage

### Basic Usage

Run the script with your PDF file as an argument:

```bash
python pdf_to_text.py input.pdf
```

This will create a searchable PDF with "_searchable" appended to the original filename.

### Advanced Options

Specify a custom output filename:
```bash
python pdf_to_text.py input.pdf --output output.pdf
```

Select OCR language (default is English):
```bash
python pdf_to_text.py input.pdf --lang deu  # For German
```

Process multiple files:
```bash
python pdf_to_text.py file1.pdf file2.pdf file3.pdf
```

## Supported Languages

The tool supports all languages that Tesseract OCR supports. Common language codes:
- eng (English)
- deu (German)
- fra (French)
- spa (Spanish)
- ita (Italian)

To use multiple languages simultaneously:
```bash
python pdf_to_text.py input.pdf --lang eng+fra
```

## Configuration

You can customize the OCR settings by creating a `config.json` file:
```json
{
    "tesseract_path": "/path/to/tesseract",
    "dpi": 300,
    "threads": 4,
    "language": "eng"
}
```

## Error Handling

Common errors and solutions:

1. **Tesseract not found**: Ensure Tesseract is installed and its path is correctly set
2. **Permission denied**: Check file permissions
3. **Out of memory**: Reduce DPI or process fewer pages simultaneously
4. **Unsupported file format**: Ensure input is a valid PDF file
5. **Virtual environment issues**: If you encounter any issues with the virtual environment, try removing the `venv` folder and running `install.bat` again

## Notes

- The processing time depends on the number of pages and the complexity of the images
- Make sure you have enough disk space as the process creates temporary image files
- The quality of the OCR depends on the quality of the original PDF
- Memory usage increases with page size and DPI settings
- For best results, ensure input PDFs are clear and well-scanned

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.