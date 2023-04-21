import click
import yaml


@click.command()
@click.option('--input-file', '-i', type=click.Path(exists=True), required=True, help='Input YAML file')
@click.option('--output-file', '-o', type=click.Path(), required=True, help='Output YAML file')
def main(input_file, output_file):
    with open(input_file, 'r') as f:
        data = yaml.safe_load(f)

    if "slots" in data:
        for slot in data["slots"]:
            if "structured_pattern" in slot:
                slot["structured_pattern"]["interpolated"] = True
                slot["structured_pattern"]["partial_match"] = True

    with open(output_file, 'w') as f:
        yaml.dump(data, f)


if __name__ == '__main__':
    main()
