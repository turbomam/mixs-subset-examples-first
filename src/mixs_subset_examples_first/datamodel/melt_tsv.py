import click
import pandas as pd


def pascal_case(s):
    words = s.split('_')
    return ''.join([word.capitalize() for word in words])


@click.command()
@click.option('--input-file', '-i', type=click.Path(exists=True), required=True, help='Input TSV file')
@click.option('--output-file', '-o', type=click.Path(), required=True, help='Output TSV file')
@click.option('--id-vars', '-k', multiple=True, required=True, help='Column(s) to use as keys')
@click.option('--value-vars', '-v', multiple=True, required=True, help='Column(s) to melt')
@click.option('--output-col-name-1', required=True, help='Name of first column')
@click.option('--output-col-name-2', required=True, help='Name of second column')
@click.option('--output-col-name-3', required=True, help='Name of third column')
def melt_tsv(input_file, output_file, id_vars, value_vars, output_col_name_1, output_col_name_2, output_col_name_3):
    """Melt a TSV file into a long key, variable, value format"""
    df = pd.read_csv(input_file, delimiter='\t')
    melted = pd.melt(df, id_vars=id_vars, value_vars=value_vars)
    # melted = melted.rename(columns={'variable': 'variable_name', 'value': 'variable_value'})
    melted['variable'] = melted['variable'].apply(pascal_case)
    renamed = melted.set_axis([output_col_name_1, output_col_name_2, output_col_name_3], axis='columns')
    renamed.to_csv(output_file, sep='\t', index=False)


if __name__ == '__main__':
    melt_tsv()
