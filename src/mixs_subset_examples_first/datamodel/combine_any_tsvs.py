import csv
import click


class TsvCombiner:
    def __init__(self, input_tsv1, input_tsv2, output_tsv, column_order):
        self.input_tsv1 = input_tsv1
        self.input_tsv2 = input_tsv2
        self.output_tsv = output_tsv
        self.column_order = column_order

    def read_tsv(self, tsv_file):
        reader = csv.DictReader(tsv_file, delimiter='\t')
        rows = list(reader)
        return rows

    def combine_tsvs(self):
        with open(self.input_tsv1, 'r') as tsv_file1, open(self.input_tsv2, 'r') as tsv_file2:

            rows1 = self.read_tsv(tsv_file1)
            rows2 = self.read_tsv(tsv_file2)

            # combine columns
            fieldnames = list(rows1[0].keys()) + [col for col in rows2[0].keys() if col not in rows1[0].keys()]

            # reorder columns
            if self.column_order:
                fieldnames = self.column_order.split(",")
                fieldnames.extend([col for col in rows1[0].keys() if col not in fieldnames])
                fieldnames.extend([col for col in rows2[0].keys() if col not in fieldnames])

            rows = []
            for row1 in rows1:
                row = {}
                for col in fieldnames:
                    row[col] = row1.get(col, "")
                rows.append(row)

            for row2 in rows2:
                row = {}
                for col in fieldnames:
                    row[col] = row2.get(col, "")
                rows.append(row)

        with open(self.output_tsv, 'w', newline='') as tsv_file:
            writer = csv.DictWriter(tsv_file, fieldnames=fieldnames, delimiter='\t')
            writer.writeheader()
            for row in rows:
                writer.writerow(row)


@click.command()
@click.option('--input-tsv1', '-i1', type=click.Path(exists=True), required=True, help='Path to input TSV file 1')
@click.option('--input-tsv2', '-i2', type=click.Path(exists=True), required=True, help='Path to input TSV file 2')
@click.option('--output-tsv', '-o', required=True, help='Path to output TSV file')
@click.option('--column-order', '-c', help='Comma-separated list of column names in desired order')
def combine_tsvs(input_tsv1, input_tsv2, output_tsv, column_order):
    tsv_combiner = TsvCombiner(input_tsv1, input_tsv2, output_tsv, column_order)
    tsv_combiner.combine_tsvs()


if __name__ == '__main__':
    combine_tsvs()
