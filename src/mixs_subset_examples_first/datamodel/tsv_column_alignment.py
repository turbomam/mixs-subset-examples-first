import csv
import click


class TsvEditor:

    def __init__(self, input_tsv, output_tsv, column_to_remove=None, rename_column=None):
        self.input_tsv = input_tsv
        self.output_tsv = output_tsv
        self.column_to_remove = column_to_remove or []
        self.rename_column = dict(rename_column or [])

    def read_tsv(self):
        with open(self.input_tsv, 'r') as tsv_file:
            reader = csv.DictReader(tsv_file, delimiter='\t')
            self.rows = list(reader)
            self.original_columns = list(self.rows[0].keys())

    def modify_tsv(self):
        blank_col_names = [s for s in self.original_columns if s.strip() == ""]
        all_cols_to_del = blank_col_names + list(self.column_to_remove)

        for row in self.rows:
            for column in all_cols_to_del:
                del row[column]
            for old_name, new_name in self.rename_column.items():
                if old_name in row:
                    row[new_name] = row[old_name]
                    del row[old_name]

    def write_tsv(self):
        managed_col_names = list(self.rows[0].keys())

        with open(self.output_tsv, 'w', newline='') as tsv_file:
            writer = csv.DictWriter(tsv_file, fieldnames=managed_col_names, delimiter='\t')
            writer.writeheader()
            for row in self.rows:
                writer.writerow(row)

    def run(self):
        self.read_tsv()
        self.modify_tsv()
        self.write_tsv()


@click.command()
@click.option('--input-tsv', '-i', type=click.Path(exists=True), required=True, help='Path to input TSV file')
@click.option('--output-tsv', '-o', required=True, help='Path to output TSV file')
@click.option('--column-to-remove', '-k', multiple=True, help='Columns to remove from the TSV')
@click.option('--rename-column', '-r', nargs=2, multiple=True, help='Rename a column (old_name new_name)')
def cli(input_tsv, output_tsv, column_to_remove, rename_column):
    editor = TsvEditor(input_tsv, output_tsv, column_to_remove, rename_column)
    editor.run()


if __name__ == '__main__':
    cli()
