import csv
import pprint

import click
from itertools import combinations


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


def extract_dicts_by_tuple(lod, x, tuple_list, excluded_cols):
    result_dict = {}
    for tup in tuple_list:
        temp = extract_dicts(lod, x, tup)
        result_dict[tup] = remove_keys(temp, excluded_cols)
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


def create_details_lod(data):
    details_lod = []
    for key, value in data.items():
        details_lod.append({"env_1": key[0], "env_2": key[1], "raw": value["raw"], "normalized": value["normalized"]})
    return details_lod


def create_summary_dod(data):
    summary_dod = {}
    for i in data:
        for env in [i["env_1"], i["env_2"]]:
            if env in summary_dod:
                summary_dod[env]["raw"].append(i["raw"])
                summary_dod[env]["normalized"].append(i["normalized"])
            else:
                summary_dod[env] = {"Environmental package": env, "raw": [i["raw"]], "normalized": [i["normalized"]]}
    return summary_dod


def create_summary_lod(data):
    details_lod = []
    for key, value in data.items():
        average_raw = sum(value["raw"]) / len(value["raw"])
        average_normalized = sum(value["normalized"]) / len(value["normalized"])
        current_dict = {"Environmental package": key, "raw": average_raw, "normalized": average_normalized}
        details_lod.append(current_dict)
    return details_lod


def calculate_contradiction_by_package(extracteds, unique_package_pairs, key):
    contradiction_by_pair_dict = {}

    for package_pair in unique_package_pairs:
        exhaustive = extracteds[package_pair]
        unique_dict_list = remove_duplicates(exhaustive)
        unique_terms_set = get_unique_values_set(exhaustive, key)
        contradiction = len(unique_dict_list) / len(unique_terms_set)
        contradiction_by_pair_dict[package_pair] = {"package_pair": package_pair, "raw": contradiction}

    return contradiction_by_pair_dict


def get_raw_min_max(data):
    raw_values = [d["raw"] for d in data.values()]
    min_max_dict = {"min": min(raw_values), "max": max(raw_values)}
    return min_max_dict


def normalize_raw(data, min_max_dict):
    for key, value in data.items():
        normalized = (value["raw"] - min_max_dict["min"]) / (min_max_dict["max"] - min_max_dict["min"])
        value["normalized"] = normalized
    return data


def add_pair_inverses(data):
    inverses = {}
    for key, value in data.items():
        inverse_key = tuple(reversed(key))
        inverses[inverse_key] = value
        inverses[inverse_key]["package_pair"] = inverse_key
    return inverses


@click.command()
@click.option('--input-tsv', required=True, type=click.Path(exists=True))
@click.option('--summary-report-tsv', required=True, type=click.Path())
@click.option('--details-report-tsv', required=True, type=click.Path())
@click.option('--excluded-cols', multiple=True)
def main(input_tsv, summary_report_tsv, details_report_tsv, excluded_cols):
    data = read_tsv_file(input_tsv)

    unique_packages_set = get_unique_values_set(data, 'Environmental package')

    unique_package_pairs = get_pairs_from_set(unique_packages_set)

    extracteds = extract_dicts_by_tuple(lod=data, x="Environmental package", tuple_list=unique_package_pairs,
                                        excluded_cols=excluded_cols)

    initial_contradiction_results = calculate_contradiction_by_package(extracteds,
                                                                       unique_package_pairs,
                                                                       'MIXS ID')

    min_max_dict = get_raw_min_max(initial_contradiction_results)

    contradiction_results_with_norm = normalize_raw(initial_contradiction_results, min_max_dict)

    contradiction_results_norm_inverses = add_pair_inverses(contradiction_results_with_norm)

    contradiction_results_plus_norm_inverses = {**contradiction_results_with_norm,
                                                **contradiction_results_norm_inverses}

    details_lod = create_details_lod(contradiction_results_plus_norm_inverses)

    with open(details_report_tsv, 'w', newline='') as file:
        writer = csv.DictWriter(file, delimiter='\t', fieldnames=details_lod[0].keys())
        writer.writeheader()
        writer.writerows(details_lod)

    summary_dod = create_summary_dod(details_lod)

    summary_lod = create_summary_lod(summary_dod)

    with open(summary_report_tsv, 'w', newline='') as file:
        writer = csv.DictWriter(file, delimiter='\t', fieldnames=summary_lod[0].keys())
        writer.writeheader()
        writer.writerows(summary_lod)


if __name__ == '__main__':
    main()
