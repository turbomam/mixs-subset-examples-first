import os

import pandas as pd

# cwd = os.getcwd()
# print(cwd)
#
# path = "../../data/"
#
# file_list = os.listdir(path)
# print(file_list)

# read the table into a pandas DataFrame
df = pd.read_csv('../../../data/hand_stacked_checklist_wide.csv', delimiter='\t')

# melt the table
melted_df = pd.melt(df, id_vars=['slot'], var_name='variable', value_name='value')

melted_df.to_csv('../../data/hand_stacked_checklist_melted.tsv', sep='\t', index=False)
