import os
import sys
import json
from pathlib import Path
import pytesseract
from pdf2image import convert_from_path

def load_config():
    """Load configuration from config.json."""
    try:
        script_dir = Path(__file__).parent.absolute()
        config_path = script_dir / 'config.json'
        print(f"Loading config from: {config_path}")
        
        if not config_path.exists():
            print(f"Error: Config file not found at {config_path}")
            sys.exit(1)
            
        with open(config_path) as f:
            config = json.load(f)
            
        # Verify Poppler path exists and contains pdftoppm.exe
        poppler_path = Path(config['poppler_path'])
        pdftoppm_path = poppler_path / 'pdftoppm.exe'
        
        if not pdftoppm_path.exists():
            print(f"Error: pdftoppm.exe not found at: {pdftoppm_path}")
            print("Please run setup.bat as administrator to install Poppler")
            sys.exit(1)
            
        print(f"Found pdftoppm at: {pdftoppm_path}")
        return config
        
    except Exception as e:
        print(f"Error loading config: {str(e)}")
        sys.exit(1)

def convert_pdf_to_text(pdf_path):
    """Convert PDF to text using OCR."""
    try:
        # Load configuration
        config = load_config()
        poppler_path = config['poppler_path']

        # Convert path to absolute
        pdf_path = Path(pdf_path).absolute()
        
        # Check if the PDF file exists
        if not pdf_path.exists():
            print(f"Error: PDF file not found: {pdf_path}")
            sys.exit(1)

        print(f"\nConverting: {pdf_path}")
        print("This may take a few minutes depending on the PDF size...")
        print(f"Using Poppler from: {poppler_path}")

        # Create output directory next to the PDF
        output_dir = pdf_path.parent / 'output'
        output_dir.mkdir(exist_ok=True)
        output_file = output_dir / f"{pdf_path.stem}_text.txt"
        
        print(f"Output will be saved to: {output_file}")

        # Convert PDF to images
        try:
            images = convert_from_path(
                str(pdf_path),
                poppler_path=poppler_path
            )
        except Exception as e:
            print(f"\nError: Failed to convert PDF to images: {str(e)}")
            print("Please make sure Poppler is installed correctly")
            sys.exit(1)

        # Process each page
        print(f"\nProcessing {len(images)} pages...")
        
        with open(output_file, 'w', encoding='utf-8') as f:
            for i, image in enumerate(images, 1):
                print(f"Processing page {i}/{len(images)}...")
                text = pytesseract.image_to_string(image)
                f.write(f"\n--- Page {i} ---\n\n")
                f.write(text)
                f.write("\n")

        print(f"\nDone! Text saved to: {output_file}")

    except Exception as e:
        print(f"\nError converting PDF: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python pdf_to_text.py <pdf_file>")
        sys.exit(1)

    convert_pdf_to_text(sys.argv[1])