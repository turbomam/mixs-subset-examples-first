import csv
import pprint

import click


@click.command()
@click.option("--input-tsv", "-f", required=True, type=click.Path(exists=True), help="Path to the TSV input.")
@click.option("--uniform-terms-out", "-u", required=True, type=click.Path(),
              help="For saving terms that only have one definition.")
@click.option("--conflicting-terms-out", "-c", required=True, type=click.Path(),
              help="For saving terms with multiple conflicting definitions.")
@click.option("--drop-field", "-d", multiple=True, help="Field(s) to drop from the TSV file.")
@click.option("--key-field", "-k", default="MIXS ID", help="Key field/index column.")
def main(input_tsv, drop_field, key_field, uniform_terms_out, conflicting_terms_out):
    """
    Reads a TSV file with DictReader and drops user-specified fields.
    Then removes duplicate rows.
    """

    key_val_list = []

    # create a set to store the unique rows
    unique_rows = set()

    # open the TSV file and create a DictReader object
    with open(input_tsv, mode="r", newline="") as tsv_file:
        reader = csv.DictReader(tsv_file, delimiter="\t")

        column_names = [x for x in reader.fieldnames if x not in list(drop_field)]
        key_index = column_names.index(key_field)

        # iterate over each row in the TSV file
        for row in reader:

            # drop the specified fields from the row
            for field in drop_field:
                if field in row:
                    del row[field]

            # get a tuple of the values for the remaining fields
            row_values = tuple(row.values())

            # if the row is not in the set of unique rows, add it to the set
            if row_values not in unique_rows:
                unique_rows.add(row_values)

    for row in unique_rows:
        key_val_list.append(row[key_index])

    key_counts = {}

    for item in key_val_list:
        if item in key_counts:
            key_counts[item] += 1
        else:
            key_counts[item] = 1

    pprint.pprint(key_counts)

    with open(uniform_terms_out, "w", newline="") as uniform_file, \
            open(conflicting_terms_out, "w", newline="") as conflicting_file:
        uniform_writer = csv.DictWriter(uniform_file, fieldnames=column_names, delimiter="\t")
        conflicting_writer = csv.DictWriter(conflicting_file, fieldnames=column_names, delimiter="\t")
        uniform_writer.writeheader()
        conflicting_writer.writeheader()
        for row in unique_rows:
            row_dict = dict(zip(column_names, row))
            key_value = row_dict[key_field]
            key_count = key_counts[key_value]
            if key_count == 1:
                uniform_writer.writerow(row_dict)
            else:
                conflicting_writer.writerow(row_dict)


if __name__ == "__main__":
    main()
