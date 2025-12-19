import os
import pandas as pd

from glob import glob

import click

def get_tool_list(pdf_filename: str, provider: str, replicate_number: int):
    """Gets the summary rows to append to the output dataframe, skipping the header
    content.
    """

    no_ext_name, _ = os.path.splitext(pdf_filename)

    input_filename = f"{no_ext_name}.{provider}.{replicate_number}.problems.txt"
    pdf_basename = os.path.basename(pdf_filename)
    

    with open(input_filename) as file_handle:
        for line in file_handle:
            if line.startswith("Resources:"):
                line = line.replace("Resources:", "").strip()

                resources = [len(line.split(";")), len(line.split("|")), len(line.split(","))]

                return {
                    "pdf_filename": pdf_basename,
                    "number_of_tools": max(resources),
                    "tools": line
                }

    
    return None

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
            records.append(get_tool_list(pdf_file, provider, replicate))

    click.echo(pd.DataFrame.from_records(records).to_csv(index=False))

if __name__ == "__main__":
    summarize()
