#!/bin/bash

# Check if at least one input PDF file is provided as an argument
if [ $# -lt 1 ]; then
    echo "Usage: $0 <input1.pdf> [input2.pdf] ..."
    exit 1
fi

# Iterate over each input PDF file
for input_pdf in "$@"; do
    if [ ! -f "$input_pdf" ]; then
        echo "Error: The input PDF file '$input_pdf' does not exist."
        continue
    fi

    # Extract the base name of the input file (without the extension)
    inputname=$(basename "$input_pdf" .pdf)

    # Check if the output PDF file already exists
    if [ -f "${inputname}-wide.pdf" ]; then
        echo "Error: The output PDF file '${inputname}-wide.pdf' already exists."
        continue
    fi

    # Use pdfjam to resize and translate the content of the PDF
    pdfjam --outfile "${inputname}-wide.pdf" --papersize '{367mm,210mm}' --scale '0.95' --offset '-40mm 0' "$input_pdf" > /dev/null 2>&1

    echo "Output PDF: ${inputname}-wide.pdf"
done

