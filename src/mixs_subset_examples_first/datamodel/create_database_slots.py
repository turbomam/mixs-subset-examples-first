import click
import re
import pandas as pd


# Define a function to convert PascalCase to snake_case
def to_snake_case(s):
    return re.sub(r'(?<!^)(?=[A-Z])', '_', s).lower()


@click.command()
@click.option('--input-file', type=click.Path(exists=True), required=True, help='Path to input TSV file')
@click.option('--output-file', type=click.Path(), required=True, help='Path to input TSV file')
@click.option('--suffix', default='_set', help='Suffix to add to the column names')
@click.option('--class_name', default='Database', help='Class name to use in the "class" column')
def main(input_file, output_file, suffix, class_name):
    # Load TSV file into pandas dataframe
    df = pd.read_csv(input_file, sep='\t')

    # Drop first row of dataframe
    df = df.drop(df.index[0])

    # print(df.columns)
    # df = df.dropna(subset=['is_a'])
    #
    # # Group rows by 'is_a' column and count the number of rows in each group
    # count_df = df.groupby('is_a').size().reset_index(name='count')
    #
    # # Display the count dataframe
    # print(count_df)

    # Create a new column with the snake_case version of the 'class' column
    df['class_snake'] = df['class'].apply(to_snake_case)

    df['slot'] = df['class_snake'] + suffix
    df['range'] = df['class']
    df['class'] = class_name
    df['multivalued'] = "true"
    df['inlined_as_list'] = "true"
    df['tree_root'] = ""

    df = df[['class', 'tree_root', 'slot', 'range', 'multivalued', 'inlined_as_list']]

    new_dict = {'class': class_name, 'tree_root': 'true'}

    # Append the dictionary as a new row to the dataframe
    df = df.append(new_dict, ignore_index=True)

    # /Users/MAM/Documents/gitrepos/mixs-subset-examples-first/src/mixs_subset_examples_first/datamodel/create_database_slots.py:47: FutureWarning: The frame.append method is deprecated and will be removed from pandas in a future version. Use pandas.concat instead.
    #   df = df.append(new_dict, ignore_index=True)

    # # but this adds the values row-wise in a new column titled "0"
    # new_row = pd.Series({'class': class_name, 'tree_root': 'true'})
    # df = pd.concat([df, new_row], ignore_index=True)

    # Save the dataframe to a new TSV file
    df.to_csv(output_file, sep='\t', index=False)


if __name__ == '__main__':
    main()
