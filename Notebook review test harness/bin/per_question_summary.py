import os
import sys

from glob import glob

def process_result(pdf_file, provider, replicate):
    filename = f"{pdf_file}.{provider}.{replicate}.txt"

    lines = []

    processing = False

    with open(filename) as fh:
        for line in fh:
            line = line.rstrip()

            if not line:
                continue

            if line.startswith("Eval Question Number"):
                processing = True
                continue

            if processing:

                line_list = line.rstrip("\r\n").split("\t")

                try:
                    question = int(line_list[0])
                except:
                    processing = False
                    continue
                
                out_line = [os.path.basename(pdf_file), str(replicate)] + line_list
        
                lines.append(out_line)
    
    return lines

def main():
    lines = []

    header = [
        "Input PDF",
        "Replicate",
        "Eval Question Number",
        "Eval Question",
        "Assessment",
        "Evidence and Reasoning",
        "Evidence Snippets",
        "Impact Level"
    ]

    print("\t".join(header))

    pdf_files = glob(f"{sys.argv[1]}/*.pdf")
    for file in pdf_files:
        for replicate in range(1, 11):
            lines.extend(process_result(file, "openai", replicate))
    
    for line in lines:
        print("\t".join(line))
    

if __name__ == "__main__":
    main()