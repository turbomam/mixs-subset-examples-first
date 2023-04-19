import click
import pandas as pd


@click.command()
@click.option('--file1', type=click.Path(exists=True), prompt='Path to first TSV file',
              help='Path to the first TSV file to merge.')
@click.option('--file2', type=click.Path(exists=True), prompt='Path to second TSV file',
              help='Path to the second TSV file to merge.')
@click.option('--on', type=str, prompt='Column name to merge on',
              help='Name of the column to merge on.')
@click.option('--output', type=click.Path(), default='merged.tsv',
              help='Path to the output TSV file. Default is "merged.tsv".')
@click.option('--col-drop-col', multiple=True, help='Drop columns with this name.')
@click.option('--row-drop-col', multiple=True, help='Drop rows with true values in this column.')
def merge_tsv_files(file1, file2, on, output, col_drop_col, row_drop_col):
    # Load the first TSV file into a DataFrame
    df1 = pd.read_csv(file1, sep='\t')
    # print(df1)

    # Load the second TSV file into a DataFrame
    df2 = pd.read_csv(file2, sep='\t')
    # print(df2)

    # Merge the two DataFrames on the specified column
    merged_df = pd.merge(df1, df2, on=on)

    drop_rows = merged_df[(merged_df[list(row_drop_col)] == True).any(axis=1)].index
    merged_df.drop(drop_rows, inplace=True)

    merged_df = merged_df.drop(columns=list(col_drop_col))

    # Write the merged DataFrame to a TSV file
    merged_df.to_csv(output, sep='\t', index=False)

    click.echo(f'Merged TSV file saved to {output}.')


if __name__ == '__main__':
    merge_tsv_files()
