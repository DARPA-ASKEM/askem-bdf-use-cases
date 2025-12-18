import os
import pandas as pd

from glob import glob

import click

def get_summary_rows(pdf_filename: str, provider: str, replicate_number: int):
    """Gets the summary rows to append to the output dataframe, skipping the header
    content.
    """

    no_ext_name, _ = os.path.splitext(pdf_filename)

    input_filename = f"{no_ext_name}.{provider}.{replicate_number}.problems.txt"
    pdf_basename = os.path.basename(pdf_filename)
    

    records = []

    processing = False
    with open(input_filename) as file_handle:
        for line in file_handle:
            if line.startswith("Error description"):
                processing = True
                continue
                        
            if processing:
                line_list = line.rstrip("\r\n").split("\t")

                record = {}
                record["dialog"] = pdf_basename
                record["provider"] = provider
                record["replicate"] = replicate_number
                record["error"] = line_list[0]
                record["impact"] = line_list[1]

                records.append(record)
    
    return records

@click.command()
@click.option("--replicates", default=3)
@click.option("--provider", default="openai")
@click.argument("input_dir", nargs=1)
def summarize(input_dir, replicates, provider):
    """Summarizes the problem sets."""

    records = []

    pdf_files = glob(f"{input_dir}/*.pdf")
    for pdf_file in pdf_files:
        for replicate in range(1, replicates + 1):
            records += get_summary_rows(pdf_file, provider, replicate)

    click.echo(pd.DataFrame.from_records(records).to_csv(index=False))

if __name__ == "__main__":
    summarize()
