import csv
import pprint

import click
import logging
import click_log
from typing import List, Tuple

click_log.basic_config(logging.getLogger())


@click.command()
@click_log.simple_verbosity_option()
@click.option('--input-tsv', type=click.Path(exists=True), help='TSV file to be filtered.')
@click.option('--output-tsv', type=click.Path(), required=True, help='File for saving filtered TSV.')
@click.option('--filter-column', required=True, help='Name of a column to be filtered.')
@click.option('--accepted-value', required=True, multiple=True,
              help='Zero or more values allowed in the filter column.')
@click.option(
    "--accept-empties/--no-accept-empties",
    default=True,
    show_default=True,
    help="Should rows with an empty values in the filter columns be accepted?",
)
def cli(input_tsv: str, output_tsv: str, filter_column: str, accepted_value: List[str], accept_empties: bool) -> None:
    """???"""

    with open(input_tsv, newline='') as tsv_file:
        reader = csv.DictReader(tsv_file, delimiter='\t')
        rows = list(reader)

    accepted_value = list(accepted_value)
    if accept_empties:
        accepted_value.append("")

    filtered = [i for i in rows if i[filter_column] in accepted_value]

    header = rows[0].keys()

    with open(output_tsv, newline='', mode="w") as tsv_file:
        writer = csv.DictWriter(tsv_file, delimiter='\t', fieldnames=header)
        writer.writeheader()
        writer.writerows(filtered)


if __name__ == '__main__':
    cli()
