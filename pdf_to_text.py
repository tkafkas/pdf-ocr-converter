import os
from pdf2image import convert_from_path
import pytesseract
from PIL import Image
from PyPDF2 import PdfWriter, PdfReader
import io
import argparse

def convert_pdf_to_searchable(input_pdf_path, output_pdf_path):
    print(f"Converting {input_pdf_path} to searchable PDF...")
    
    # Convert PDF pages to images
    print("Converting PDF to images...")
    images = convert_from_path(input_pdf_path)
    
    # Create a PDF writer object
    pdf_writer = PdfWriter()
    
    # Process each page
    for i, image in enumerate(images, start=1):
        print(f"Processing page {i}/{len(images)}...")
        
        # Perform OCR on the image
        text = pytesseract.image_to_pdf_or_hocr(image, extension='pdf')
        
        # Convert bytes to PDF page
        pdf = PdfReader(io.BytesIO(text))
        page = pdf.pages[0]
        
        # Add the searchable page to output PDF
        pdf_writer.add_page(page)
    
    # Save the searchable PDF
    print(f"Saving searchable PDF to {output_pdf_path}...")
    with open(output_pdf_path, 'wb') as output_file:
        pdf_writer.write(output_file)
    
    print("Conversion complete!")

def main():
    parser = argparse.ArgumentParser(description='Convert image-based PDF to searchable PDF')
    parser.add_argument('input_pdf', help='Path to input PDF file')
    parser.add_argument('--output', help='Path to output PDF file (optional)', default=None)
    args = parser.parse_args()
    
    input_pdf = args.input_pdf
    if not os.path.exists(input_pdf):
        print(f"Error: Input file '{input_pdf}' does not exist")
        return
    
    # Generate output path if not provided
    output_pdf = args.output
    if output_pdf is None:
        base_name = os.path.splitext(input_pdf)[0]
        output_pdf = f"{base_name}_searchable.pdf"
    
    convert_pdf_to_searchable(input_pdf, output_pdf)

if __name__ == "__main__":
    main()