import pandas as pd
import click


@click.command()
@click.option('--input-file', help='Path to input TSV file')
@click.option('--output-file', help='Path to output TSV file')
def generate_combined_dataframe(input_file, output_file):
    # Load input TSV file into a Pandas dataframe
    df = pd.read_csv(input_file, sep='\t', dtype=str)
    input_row_count = df.shape[0]
    print(f"Input file contains {input_row_count} rows (after removing ONE of the two header rows)")

    # Split dataframe into rows where is_a = 'Checklist' and 'EnvironmentalPackage'
    checklist_df = df.loc[df['is_a'] == 'Checklist']
    checklist_row_count = checklist_df.shape[0]
    print(f"{checklist_row_count = }")
    env_package_df = df.loc[df['is_a'] == 'EnvironmentalPackage']
    env_package_row_count = env_package_df.shape[0]
    print(f"{env_package_row_count = }")
    print("Row mismatch can be attributed to extra header rows, is_a parent classes, "
          "other non-Checklist/non-EnvironmentalPackage rows")

    expected_combinations_count = checklist_row_count * env_package_row_count
    print(f"{expected_combinations_count = }")

    # Create an empty list to store the combined rows
    combined_rows = []

    # Iterate through each row in the checklist dataframe
    for i, row in checklist_df.iterrows():

        # Iterate through each row in the environmental package dataframe
        for j, env_row in env_package_df.iterrows():
            # Create a new combined row
            new_row = {
                'class': f"{row['class']}{env_row['class']}",
                'title': f"{env_row['title']} sample according to the {row['class']} checklist",
                'aliases': row['aliases'],
                'class_uri': f"{row['class_uri']}_{env_row['class_uri'].split(':')[1]}",
                'description': env_row['description'],
                'in_subset': row['in_subset'],
                'is_a': env_row['class'],
                'mixin': '',
                'mixins': row['class']
            }

            # Append the new row to the list of combined rows
            combined_rows.append(new_row)

    # Convert the list of combined rows to a Pandas dataframe
    combinations_df = pd.DataFrame(combined_rows)

    combinations_row_count = combinations_df.shape[0]
    print(f"{combinations_row_count = }")

    # Write the combined dataframe to a TSV file
    combinations_df.to_csv(output_file, sep='\t', index=False)
