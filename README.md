# PDF OCR Converter

This Python application converts image-based PDFs into searchable text PDFs using OCR (Optical Character Recognition).

## Prerequisites

1. Python 3.7 or higher
2. Tesseract OCR must be installed on your system:
   - Windows: Download and install from https://github.com/UB-Mannheim/tesseract/wiki
   - Linux: `sudo apt-get install tesseract-ocr`
   - Mac: `brew install tesseract`

## Installation

1. Clone or download this repository
2. Install Python dependencies:
```bash
pip install -r requirements.txt
```

## Usage

Run the script with your PDF file as an argument:

```bash
python pdf_to_text.py input.pdf
```

This will create a searchable PDF with "_searchable" appended to the original filename.

To specify a custom output filename:

```bash
python pdf_to_text.py input.pdf --output output.pdf
```

## Notes

- The processing time depends on the number of pages and the complexity of the images
- Make sure you have enough disk space as the process creates temporary image files
- The quality of the OCR depends on the quality of the original PDF