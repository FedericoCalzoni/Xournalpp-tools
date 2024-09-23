#!/bin/bash

# Usage: ./optimize_pdf.sh input.pdf output.pdf

if [ $# -lt 2 ]; then
  echo "Usage: $0 input.pdf output.pdf"
  exit 1
fi

input_pdf="$1"
output_pdf="$2"

if ! command -v gs &> /dev/null; then
  echo "Ghostscript (gs) could not be found. Please install it and try again."
  exit 1
fi

temp_optimized_pdf=$(mktemp --suffix=.pdf)

echo "Optimizing PDF..."
if ! gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.5 \
   -dPDFSETTINGS=/ebook -dDetectDuplicateImages=true \
   -dDownsampleColorImages=true -dColorImageResolution=150 \
   -dGrayImageResolution=150 -dMonoImageResolution=150 \
   -dSubsetFonts=true -dEmbedAllFonts=true \
   -dDiscardAllComments=true -dJPEGQ=80 \
   -dNumRenderingThreads=4 \
   -dFASTWEBVIEW=true -sOutputFile="$temp_optimized_pdf" "$input_pdf"; then
  echo "Error during PDF optimization."
  rm "$temp_optimized_pdf"
  exit 1
fi

echo "Finalizing output..."
if ! gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.5 \
   -sOutputFile="$output_pdf" "$temp_optimized_pdf"; then
  echo "Error during finalizing output."
  rm "$temp_optimized_pdf"
  exit 1
fi

rm "$temp_optimized_pdf"

echo "PDF optimization complete. Output file: $output_pdf"