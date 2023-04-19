import re

import click


@click.command()
@click.option('--input-tsv', '-i', type=click.Path(exists=True), help='Input TSV file name', required=True)
@click.option('--output-tsv', '-o', help='Output TSV file name', required=True)
def print_headers(input_tsv, output_tsv):
    with open(input_tsv, 'r') as f:
        headers = f.readline().strip().split('\t')
        headers = [re.sub(r'[\s_/-]+(\w)', lambda m: m.group(1).upper(), value.title()) for value in
                   headers]
        headers = ['class', '> class'] + sorted(headers)
        with open(output_tsv, 'w') as new_f:
            new_f.write('\n'.join(headers))


if __name__ == '__main__':
    print_headers()
