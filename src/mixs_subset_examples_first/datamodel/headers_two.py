import csv
import re

import click


@click.command()
@click.option('--input-tsv', '-i', type=click.Path(exists=True), help='Input TSV file name', required=True)
@click.option('--output-tsv', '-o', help='Output TSV file name', required=True)
def print_headers(input_tsv, output_tsv):
    with open(input_tsv, 'r') as i_f:
        headers = i_f.readline().strip().split('\t')
        lod = []
        for header in headers:
            modified = re.sub(r'[\s_/-]+(\w)', lambda m: m.group(1).upper(), header.title())
            lod.append({'original': header, 'modified': modified})

        with open(output_tsv, 'w', newline='') as o_f:
            writer = csv.DictWriter(o_f, delimiter='\t', fieldnames=["modified", "original"])
            writer.writerows(lod)


if __name__ == '__main__':
    print_headers()
