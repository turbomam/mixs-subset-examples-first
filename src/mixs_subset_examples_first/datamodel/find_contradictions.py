import click
import csv
import yaml


@click.command()
@click.option('--input-file', type=click.Path(exists=True), help='Input TSV file name')
@click.option('--output-file', type=click.Path(), help='Output YAML file name')
@click.option('--key1', type=str, help='First key column name')
@click.option('--key2', type=str, help='Second key column name')
@click.option('--value', type=str, help='Column name to append')
def main(input_file, output_file, key1, key2, value):
    data = {}
    with open(input_file, newline='') as f:
        reader = csv.DictReader(f, delimiter='\t')
        for row in reader:
            if row[key1] not in data:
                data[row[key1]] = {}
            if row[key2] not in data[row[key1]]:
                data[row[key1]][row[key2]] = {}
            if value in data[row[key1]][row[key2]]:
                data[row[key1]][row[key2]][value].append(row[value])
            else:
                data[row[key1]][row[key2]][value] = [row[value]]

    with open(output_file, 'w') as f:
        yaml.dump(data, f)

if __name__ == 'main':
    main()
