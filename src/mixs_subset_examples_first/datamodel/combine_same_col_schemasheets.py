import csv
import click


@click.command()
@click.option('--input1', type=click.Path(exists=True), help='Path to the first input TSV file')
@click.option('--input2', type=click.Path(exists=True), help='Path to the second input TSV file')
@click.option('--output', type=click.Path(), help='Path to the output TSV file')
def combine_tsvs(input1, input2, output):
    with open(input1, 'r', newline='') as f1, \
            open(input2, 'r', newline='') as f2, \
            open(output, 'w', newline='') as f_out:
        reader1 = csv.reader(f1, delimiter='\t')
        input1_all_rows_count = sum(1 for row in reader1)
        print(f"{input1_all_rows_count = }")
        f1.seek(0)

        reader2 = csv.reader(f2, delimiter='\t')
        input2_all_rows_count = sum(1 for row in reader2)
        print(f"{input2_all_rows_count = }")
        f2.seek(0)

        writer = csv.writer(f_out, delimiter='\t')

        # Write header rows from input1
        header1 = next(reader1)
        header2 = next(reader1)
        writer.writerow(header1)
        writer.writerow(header2)

        # Write data rows from input1
        for row in reader1:
            writer.writerow(row)

        # Skip header rows in input2
        next(reader2)
        # next(reader2)

        # Write data rows from input2
        for row in reader2:
            writer.writerow(row)

    click.echo(f"Successfully combined {input1} and {input2} into {output}")
