#!/bin/bash

# Check if the input PDF file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_pdf>"
    exit 1
fi

# Configuration
SCALE=0.9
PAPERWIDTH=210
MAXPAPERHIGHT=297

INPUT_DIR=$(dirname "$1")
INPUT_PDF=$(basename "$1")
TEMP_DIR="/tmp/OpenWithXournalpp"
mkdir -p "$TEMP_DIR"
TEMP1_PDF=$(mktemp --suffix=.pdf --tmpdir="$TEMP_DIR")
TEMP2_PDF=$(mktemp --suffix=.pdf --tmpdir="$TEMP_DIR")
TEMP3_PDF=$(mktemp --suffix=.pdf --tmpdir="$TEMP_DIR")
OUTPUT_DIR="/home/federico/Documents/.PDFXournalpp"
OUTPUT_PDF="$OUTPUT_DIR"/"$INPUT_PDF"
PAPERRATIO=$(echo "scale=2; $PAPERWIDTH / $MAXPAPERHIGHT" | bc)

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Step 0: Analyze the input PDF
echo "Analyzing the input PDF..."
PDFWIDTH=$(pdfinfo "$INPUT_DIR"/"$INPUT_PDF" | grep "Page size" | awk '{print $3}')
PDFHIGHT=$(pdfinfo "$INPUT_DIR"/"$INPUT_PDF" | grep "Page size" | awk '{print $5}')
PDFRATIO=$(echo "scale=2; $PDFWIDTH / $PDFHIGHT" | bc)

if [ $(echo "$PDFRATIO >= $PAPERRATIO" | bc) -eq 1 ]; then
  OFFSET=$(echo "scale=2; ($PAPERWIDTH - ($PAPERWIDTH * $SCALE))/-2" | bc)
  HFIT=$(echo "scale=2; $PAPERWIDTH / $PDFRATIO" | bc)
else
  WFIT=$(echo "scale=2; $MAXPAPERHIGHT * $PDFRATIO " | bc)
  HFIT=$MAXPAPERHIGHT
  OFFSET=$(echo "scale=2; ($PAPERWIDTH - $WFIT)/-2 + ($WFIT- ($WFIT * $SCALE))/-2" | bc)
fi


PAPERHIGHT=$(echo "$HFIT * $SCALE" | bc)

RIGHT=$(echo "$PAPERWIDTH * 2.83465" | bc)
BOTTOM=$(echo "($MAXPAPERHIGHT - $PAPERHIGHT)/2 * 2.83465" | bc)
TOP=$(echo "$PAPERHIGHT * 2.83465 + $BOTTOM"| bc)


# Step 1: Add margins to the PDF
echo "Adding margins to the PDF..."
pdfjam --outfile "$TEMP1_PDF" --papersize "{$PAPERWIDTH mm, $MAXPAPERHIGHT mm}" --scale "$SCALE" --offset "${OFFSET}mm 0" --trim '0mm 0mm 0mm 0mm' --clip false "$INPUT_DIR/$INPUT_PDF" > /dev/null 2>&1
pdfcrop "$TEMP1_PDF" "$TEMP2_PDF" --bbox "0 ${BOTTOM} ${RIGHT} ${TOP}"> /dev/null 2>&1


# Step 2: Optimize the PDF (1st pass)
echo "Optimizing PDF..."
if ! gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/ebook -dDetectDuplicateImages=true \
   -dDownsampleColorImages=true \
   -dJPEGQuality=100 -dColorImageDownsampleType=/Bicubic \
   -dColorImageResolution=150 -dGrayImageResolution=150 -dMonoImageResolution=150 \
   -dSubsetFonts=true -dEmbedAllFonts=true \
   -dDiscardAllComments=true -dNumRenderingThreads=4 \
   -dFASTWEBVIEW=true -sOutputFile="$TEMP3_PDF" "$TEMP2_PDF"; then
  echo "Error during PDF optimization."
  exit 1
fi

# Step 2: Optimize the PDF (2nd pass)
echo "Finalizing output..."
if ! gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite  -dPDFSETTINGS=/ebook -dCompatibilityLevel=1.4 \
   -sOutputFile="$OUTPUT_PDF" "$TEMP3_PDF"; then
  echo "Error during finalizing output."
  exit 1
fi

# Clean up temporary files
rm "$TEMP1_PDF" "$TEMP2_PDF" "$TEMP3_PDF"

# Step 3: Open the optimized PDF with Xournal++
echo "Opening the optimized PDF with Xournal++..."
xournalpp "$OUTPUT_PDF" &

exit 0
