import csv
import click
import re


@click.command()
@click.option('--input-tsv', '-i', type=click.Path(exists=True), help='Input TSV file name', required=True)
@click.option('--output-tsv', '-o', help='Output TSV file name', required=True)
@click.option('--column', '-c', help='Column name to extract unique values from', required=True)
def extract_unique_values(input_tsv, output_tsv, column):
    with open(input_tsv, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter='\t')
        unique_values = set()
        for row in reader:
            unique_values.add(row[column])
        unique_values = sorted(unique_values)

        # Apply substitutions and case changes to the unique values
        modified_unique_values = [re.sub(r'[\s_/-]+(\w)', lambda m: m.group(1).upper(), value.title()) for value in
                                  unique_values]

        # Write out two columns: original values and modified values
        with open(output_tsv, 'w', newline='') as outfile:
            writer = csv.writer(outfile, delimiter='\t')
            for values in zip(modified_unique_values, unique_values):
                writer.writerow(values)


if __name__ == '__main__':
    extract_unique_values()
