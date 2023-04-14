import pprint

import click
import csv
import yaml
import copy
import requests
import xmltodict
import json


@click.command()
@click.option('--input-file', type=click.Path(exists=True), help='Input TSV file name')
@click.option('--attributes-file', type=click.Path(exists=True), help='NCBI Biosample attributes XML file name')
@click.option('--attributes-key', help='Search for key1 values from the input against this key in the attributes file')
@click.option('--output-file', type=click.Path(), help='Output YAML file name')
@click.option('--key1', type=str, help='First key column name')
@click.option('--key2', type=str, help='Second key column name')
@click.option('--context', type=str, help='Column that provides context for contradicted values')
# @click.option('--attributes-reference', default="https://www.ncbi.nlm.nih.gov/biosample/docs/attributes/?format=xml",
#               help="URL for NCBI's biosample attributes XML file")
def main(input_file, output_file, key1, key2, context, attributes_file, attributes_key):
    # attribs_response = requests.get(attributes_reference)
    # attribs_xml_data = attribs_response.content
    #
    # # convert XML data to dictionary
    # attribs_ordered = xmltodict.parse(attribs_xml_data)
    #
    # # biosample_attribs = json.loads(json.dumps(attribs_ordered))

    with open(attributes_file, encoding='utf-8') as fd:
        attribs_ordered = xmltodict.parse(fd.read())

    ncbi_acknowledged = [i[attributes_key] for i in attribs_ordered['BioSampleAttributes']['Attribute'] if
                         attributes_key in i]

    with open(input_file, newline='') as f:
        reader = csv.DictReader(f, delimiter='\t')
        data = [row for row in reader]

    # report = {key1: {}, key2: {}}
    report = {key1: {}}
    see_alsos = {}

    for row in data:
        if row[key1] in report[key1] and key2 in report[key1][row[key1]] and row[key2] in report[key1][row[key1]][
            key2] and context in report[key1][row[key1]][key2][row[key2]]:
            report[key1][row[key1]][key2][row[key2]][context].append(row[context])
        elif row[key1] in report[key1] and key2 in report[key1][row[key1]] and row[key2] in report[key1][row[key1]][
            key2]:
            report[key1][row[key1]][key2][row[key2]][context] = [row[context]]
        elif row[key1] in report[key1] and key2 in report[key1][row[key1]]:
            report[key1][row[key1]][key2][row[key2]] = {context: [row[context]]}
        elif row[key1] in report[key1]:
            report[key1][row[key1]][key2] = {row[key2]: {context: [row[context]]}}
        else:
            report[key1][row[key1]] = {key2: {row[key2]: {context: [row[context]]}}}

        if row[key2] in see_alsos:
            see_alsos[row[key2]].append(row[key1])
        else:
            see_alsos[row[key2]] = [row[key1]]

    report_copy = copy.deepcopy(report)

    for k1, k1o in report[key1].items():
        if len(k1o[key2]) == 1:
            del report_copy[key1][k1]
        else:
            for k2, k2o in k1o.items():
                for k2v, k2vo in k2o.items():
                    report_copy[key1][k1][k2][k2v]["NCBI acknowledged"] = k2v in ncbi_acknowledged
                    remove_self = list(set(see_alsos[k2v]) - set([k1]))
                    if len(remove_self) > 0:
                        report_copy[key1][k1][k2][k2v]["see_also"] = remove_self

    with open(output_file, 'w') as f:
        yaml.dump(report_copy, f)

    # print(yaml.dump(report_copy, default_flow_style=False, sort_keys=True))


if __name__ == 'main':
    main()
