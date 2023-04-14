import csv
import sys

import click
import logging
import click_log
from typing import List, Tuple

import yaml

click_log.basic_config(logging.getLogger())


class TSVFile:
    def __init__(self, path: str) -> None:
        self.path = path
        self.headers = self._read_headers()

    def _read_headers(self) -> List[str]:
        """Read the headers from a TSV file."""
        with open(self.path, 'r', newline='') as tsv_file:
            reader = csv.reader(tsv_file, delimiter='\t')
            headers = next(reader)
        return headers

    def compare_headers(self, other: 'TSVFile') -> Tuple[set, set, set]:
        """Compare the headers of two TSV files and determine their intersection and set differences."""
        intersection = set(self.headers) & set(other.headers)
        set_difference_self = set(self.headers) - set(other.headers)
        set_difference_other = set(other.headers) - set(self.headers)
        return intersection, set_difference_self, set_difference_other


@click.command()
@click_log.simple_verbosity_option()
@click.option('--file1', type=click.Path(exists=True), help='First TSV file to compare.')
@click.option('--file2', type=click.Path(exists=True), help='Second TSV file to compare.')
@click.option('--output-yaml', type=click.Path(), help='YAML file for dumping comparison.')
def cli(file1: str, file2: str, output_yaml: str) -> None:
    """Compare the headers of two TSV files and determine their intersection and set differences."""
    tsv_file_1 = TSVFile(file1)
    tsv_file_2 = TSVFile(file2)

    intersection, set_difference_1, set_difference_2 = tsv_file_1.compare_headers(tsv_file_2)

    # click.echo(f"Intersection: {intersection}")
    # click.echo(f"Set difference ({file1} - {file2}): {set_difference_1}")
    # click.echo(f"Set difference ({file2} - {file1}): {set_difference_2}")

    report_obj = {f"{file1} only": list(set_difference_1),
                  f"{file2} only": list(set_difference_2),
                  "Intersection": list(intersection)}

    # yaml.dump(report_obj, sys.stdout, default_flow_style=False)

    with open(output_yaml, "w") as f:
        yaml.dump(report_obj, f)


if __name__ == '__main__':
    cli()
