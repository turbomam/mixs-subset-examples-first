import csv
from collections import defaultdict
import click


def report_multi_pairings(data, column_a, column_b):
    # Initialize dictionaries to hold the pairings
    pairings_a = defaultdict(set)
    pairings_b = defaultdict(set)

    # Iterate over the rows in the data and add the pairings to the dictionaries
    for row in data:
        val_a = row[column_a]
        val_b = row[column_b]
        pairings_a[val_a].add(val_b)
        pairings_b[val_b].add(val_a)

    # Report any pairings where a value in column A is paired with multiple values in column B
    for val_a, set_b in pairings_a.items():
        if len(set_b) > 1:
            print(f"{column_a} value: {val_a} is paired with multiple values in {column_b}: {set_b}")

    # Report any pairings where a value in column B is paired with multiple values in column A
    for val_b, set_a in pairings_b.items():
        if len(set_a) > 1:
            print(f"{column_b} value: {val_b} is paired with multiple values in {column_a}: {set_a}")


@click.command()
@click.option('--input_tsv', '-i', type=click.Path(exists=True),
              help='TSV  files with potential multi-pairings between column_a and column_b')
@click.option('--column_a', '-a', required=True, help='Name of column A')
@click.option('--column_b', '-b', required=True, help='Name of column B')
def main(input_tsv, column_a, column_b):
    # Read the TSV file into a list of dictionaries
    with open(input_tsv, 'r') as tsv_file:
        reader = csv.DictReader(tsv_file, delimiter='\t')
        data = list(reader)

    # Call the report_multi_pairings function
    report_multi_pairings(data, column_a, column_b)


if __name__ == '__main__':
    main()
