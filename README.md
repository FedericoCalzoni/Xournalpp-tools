# Xournalpp-tools

## PDF-Margin
Small script to resize and add a margin to the right side of a PDF file. 

An example usecase is to use the generated PDF with some handwriting notetaking APP like Xournalpp
and take your notes to the side of the pdf. 

It uses pdfjam to perform the adjustments. [see pdfjam](https://github.com/rrthomas/pdfjam).
Usually shipped with texlive package.

### Usage
To use the script, pass the path to the input PDF file as an argument:

``` bash
./PDF-Margin.sh <input.pdf>
```
The script will create a new PDF file with the desired dimensions.  

## Xopp Merger

### Description

`Xopp Merger` is a Python script designed to merge multiple `.xopp` files (used by [Xournal++](https://github.com/xournalpp/xournalpp)) with PDF backgrounds into a single `.xopp` file.

### Requirements

- Python 3.x
- Required Python packages: `glob`, `os`, `shutil`, `gzip`, `pikepdf`, `sys`, `natsort`

### Usage

- place merge-xopp.py in the same folder as the .xopp files. 
- run the script: 
```bash
python xopp_merger.py
```
- Done! you will find the output inside a new folder called `output-xopp-merger` together with the merged PDF background

The order of the merged files is alphabetical.

### Note
The script has not been tested extensively, feel free to report bugs.

## OpenWithXournalpp

### Description

`OpenWithXournalpp` is a Bash script that takes a PDF file, optimizes it by adjusting the margins and scaling it to fit a standard paper size, and then opens it in [Xournal++](https://github.com/xournalpp/xournalpp) for annotating. This is useful when you want to add annotations or handwriting to the sides of a PDF document.

### Requirements

- Bash
- `pdfjam` (included in `texlive`)
- `pdfcrop`
- `ghostscript` (`gs` command)
- [Xournal++](https://github.com/xournalpp/xournalpp)

### Usage

1. Save the script as `OpenWithXournalpp.sh` and make it executable:

```bash
chmod +x OpenWithXournalpp.sh
```

2. Run the script with a PDF file as an argument:

```bash
./OpenWithXournalpp.sh <input.pdf>
```

The script will process the PDF, adding margins, optimizing the file size, and then opening it with Xournal++ for annotation.