import csv
import pprint

import click
from itertools import combinations

excluded_keys = [
    "Environmental package",
    "Example",
    "Preferred unit",
    "Section",
]


def read_tsv_file(file_path, delimiter='\t'):
    with open(file_path, 'r', encoding='utf-8') as tsv_file:
        reader = csv.DictReader(tsv_file, delimiter=delimiter)
        rows = [row for row in reader]
    return rows


def get_unique_values_set(lod, key):
    values = set()
    for d in lod:
        if key in d:
            values.add(d[key])
    return values


def get_pairs_from_set(s):
    return list(combinations(s, 2))


def extract_dicts(lod, x, s):
    return [d for d in lod if d.get(x) in s]


def extract_dicts_by_tuple(lod, x, tuple_list):
    result_dict = {}
    for tup in tuple_list:
        temp = extract_dicts(lod, x, tup)
        result_dict[tup] = remove_keys(temp, excluded_keys)
    return result_dict


def remove_keys(lod, droppers):
    new_lod = []
    for d in lod:
        new_d = {k: v for k, v in d.items() if k not in droppers}
        new_lod.append(new_d)
    return new_lod


def remove_duplicates(lod):
    unique_dicts = []
    for d in lod:
        if d not in unique_dicts:
            unique_dicts.append(d)
    return unique_dicts


def count_duplicated_values(data, key):
    unique_values = {}
    for d in data:
        value = d[key]
        if value in unique_values:
            unique_values[value] += 1
        else:
            unique_values[value] = 1
    return {k: v for k, v in unique_values.items() if v > 1}


def dict_list_average(data):
    result = {}
    for key, lst in data.items():
        result[key] = sum(lst) / len(lst)
    return result


def has_matching_dict(data, key1, val1, key2, val2):
    for d in data:
        if ((d.get(key1) == val1 and d.get(key2) == val2) or
                (d.get(key1) == val2 and d.get(key2) == val1)):
            return True
    return False


def calculate_contradiction_by_package(extracteds, unique_package_pairs, key):
    contradiction_by_package = {}
    contradiction_by_pair = []
    for package_pair in unique_package_pairs:
        exhaustive = extracteds[package_pair]
        unique_dict_list = remove_duplicates(exhaustive)
        unique_terms_set = get_unique_values_set(exhaustive, key)
        contradiction = len(unique_dict_list) / len(unique_terms_set)
        # print(f"{package_pair =}; {contradiction = }")
        for package_element in package_pair:
            if package_element not in contradiction_by_package:
                contradiction_by_package[package_element] = [contradiction]
            else:
                contradiction_by_package[package_element].append(contradiction)

            if has_matching_dict(contradiction_by_pair, "env1", package_pair[0], "env2", package_pair[1]):
                pass
            else:
                contradiction_by_pair.append(
                    {"env1": package_pair[0], "env2": package_pair[1], "contradiction": contradiction})
                contradiction_by_pair.append(
                    {"env1": package_pair[1], "env2": package_pair[0], "contradiction": contradiction})

        # duplicate_value_count = count_duplicated_values(unique_dict_list, 'MIXS ID')
        # pprint.pprint(duplicate_value_count)
        # duplicated_keys = list(duplicate_value_count.keys())
        # dupe_details = extract_dicts(lod=unique_dict_list, x='MIXS ID', s=duplicated_keys)
        # pprint.pprint(dupe_details)

    return contradiction_by_package, contradiction_by_pair


def normalize_dict_values(data):
    # Get the minimum and maximum values from the dictionary
    min_value = min(data.values())
    max_value = max(data.values())

    # Create a new dictionary with normalized values
    result = {}
    for key, value in data.items():
        result[key] = (value - min_value) / (max_value - min_value)

    return result


@click.command()
@click.option('--input-tsv', required=True, type=click.Path(exists=True))
@click.option('--averages-report-tsv', required=True, type=click.Path())
@click.option('--details-report-tsv', required=True, type=click.Path())
def worst_offender(input_tsv, averages_report_tsv, details_report_tsv):
    data = read_tsv_file(input_tsv)

    unique_packages_set = get_unique_values_set(data, 'Environmental package')

    unique_package_pairs = get_pairs_from_set(unique_packages_set)

    extracteds = extract_dicts_by_tuple(lod=data, x="Environmental package", tuple_list=unique_package_pairs)

    contradiction_by_package, contradiction_by_pair = calculate_contradiction_by_package(extracteds,
                                                                                         unique_package_pairs,
                                                                                         'MIXS ID')

    average_contradiction_by_package = dict_list_average(contradiction_by_package)

    normalized_contradiction_by_package = normalize_dict_values(average_contradiction_by_package)

    with open(averages_report_tsv, 'w', encoding='utf-8') as tsv_file:
        writer = csv.writer(tsv_file, delimiter='\t')
        writer.writerow(['Environmental package', 'Normalized average contradiction'])
        for k, v in normalized_contradiction_by_package.items():
            writer.writerow([k, v])

    # with open(details_report_tsv, 'w', encoding='utf-8') as tsv_file:
    #     header = list(contradiction_by_pair[0].keys())
    #     writer = csv.writer(tsv_file, delimiter='\t')
    #     writer.writerow(header)
    #     for row in contradiction_by_pair:
    #         # writer.writerow(row)
    #         pprint.pprint(row)

    with open(details_report_tsv, 'w', newline='') as file:
        writer = csv.DictWriter(file, delimiter='\t', fieldnames=contradiction_by_pair[0].keys())
        writer.writeheader()
        writer.writerows(contradiction_by_pair)


if __name__ == '__main__':
    worst_offender()
