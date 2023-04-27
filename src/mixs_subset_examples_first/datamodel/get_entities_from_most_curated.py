import pprint

import pandas as pd

import os

curated_slots_file = '../../../data/mixs_combined_all_modified_lossy_deduped.tsv'
curated_slots_name_column = "Structured comment name"
# this is a slots only file!

raw_env_packages_file = '../../../data/mixs_v6_environmental_packages.tsv'
raw_env_packages_slots_name_column = "Structured comment name"

raw_checklists_file = '../../../data/mixs_v6_MIxS.tsv'
raw_checklists_slots_name_column = "Structured comment name"

# cwd = os.getcwd()
# print(cwd)
#
# path = "../../../data"
#
# file_list = os.listdir(path)
# print(file_list)

# read the TSV file and treat the first row as the column headers
curated_slots_frame = pd.read_csv(curated_slots_file, sep='\t', header=0)

raw_env_packages_frame = pd.read_csv(raw_env_packages_file, sep='\t', header=0)
raw_env_packages_slots_unique_names = raw_env_packages_frame[raw_env_packages_slots_name_column].unique()
raw_env_packages_slots_unique_names.sort()
# print(raw_env_packages_frame)


raw_checklists_frame = pd.read_csv(raw_checklists_file, sep='\t', header=0)
raw_checklists_unique_names = raw_checklists_frame[raw_checklists_slots_name_column].unique()
raw_checklists_unique_names.sort()
# print(raw_checklists_unique_names)
# print(raw_checklists_frame.columns)

# discard rows where the 'MIXS ID' column starts with '>'
curated_slots_frame = curated_slots_frame[~curated_slots_frame['MIXS ID'].str.startswith('>')]

curated_slots_unique_names = curated_slots_frame[curated_slots_name_column].unique()
curated_slots_unique_names.sort()
# print(curated_slots_unique_names)

curated_slots_not_any_raw = list(
    set(curated_slots_unique_names) - (set(raw_env_packages_slots_unique_names) | set(raw_checklists_unique_names)))
curated_slots_not_any_raw.sort()
pprint.pprint(curated_slots_not_any_raw)

raw_checklist_slots_not_curated = list(set(raw_checklists_unique_names) - set(curated_slots_unique_names))
raw_checklist_slots_not_curated.sort()
pprint.pprint(raw_checklist_slots_not_curated)

raw_env_packages_slots_only = list(set(raw_env_packages_slots_unique_names) - set(curated_slots_unique_names))
raw_env_packages_slots_only.sort()
pprint.pprint(raw_env_packages_slots_only)

# print(curated_slots_frame.columns)

# Index(['MIXS ID', 'Structured comment name', 'identifier', 'Item', 'aliases',
#        'range', 'structured_pattern', 'minimum_value', 'maximum_value',
#        'multivalued', 'Occurrence - > multivalued, vmap: {1: false, m: true}',
#        'see_also', 'examples', 'Example', 'todos', 'comments', 'notes',
#        'Preferred unit', 'Definition', 'Expected value', 'Value syntax',
#        'temporal likely', 'enum likely', 'semantic root'],
#       dtype='object')

# print(curated_slots_frame)
