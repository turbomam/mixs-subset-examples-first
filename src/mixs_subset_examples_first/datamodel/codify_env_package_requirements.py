import click
import pandas as pd


@click.command()
@click.option('--ep-file', type=click.Path(exists=True), default='../data/mixs_v6_environmental_packages.tsv',
              help='Path to EP file')
@click.option('--pascal-case-file', type=click.Path(exists=True),
              default='../data/mixs_v6_checklists_env_packages_classes_curated.tsv', help='Path to pascal case file')
@click.option('--req-code-file', type=click.Path(exists=True), default='../data/mixs_requirement_codes.tsv',
              help='Path to requirement codes file')
@click.option('--output-file', type=click.Path(),
              default='../data/mixs_v6_environmental_packages_pascal_case_req_rec.tsv',
              help='Path for writing output')
def merge_dataframes(ep_file, pascal_case_file, req_code_file, output_file):
    # load the data
    ep_raw_df = pd.read_csv(ep_file, sep="\t")
    print(ep_raw_df.shape)

    pascal_case_class_df = pd.read_csv(pascal_case_file, sep="\t")
    print(pascal_case_class_df.shape)

    req_code_df = pd.read_csv(req_code_file, sep="\t")
    print(req_code_df.shape)

    ep_pascal_reqs = pd.merge(ep_raw_df, pascal_case_class_df, left_on='Environmental package', right_on='title',
                              how='left')
    print(ep_pascal_reqs.shape)

    ep_pascal_reqs = pd.merge(ep_pascal_reqs, req_code_df, left_on='Requirement', right_on='mixs_requirement_value',
                              how='left')
    print(ep_pascal_reqs.shape)
    print(ep_pascal_reqs.columns)

    ep_pascal_reqs['not applicable'] = ep_pascal_reqs['not applicable'].astype(bool)

    # ep_pascal_reqs = ep_pascal_reqs[~ep_pascal_reqs['not applicable']]
    # # might want to split first and check the two subsets
    #
    # print(ep_pascal_reqs.shape)

    # ep_pascal_reqs = ep_pascal_reqs.drop(
    #     columns=['Environmental package', 'MIXS ID', 'Unnamed: 11', 'Unnamed: 12', 'mixs_requirement_value',
    #              'mixs_name', 'mixs_desc', 'mixs_citation', 'not applicable', 'optional', ])

    ep_pascal_reqs = ep_pascal_reqs[["class", "Structured comment name", 'recommended', 'required']]

    print(ep_pascal_reqs.columns)

    ep_pascal_reqs.to_csv(output_file, sep='\t', index=False)


if __name__ == '__main__':
    merge_dataframes()
