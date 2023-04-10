# mixs-subset-examples-first

A subset of the MIxS specification that's self-documenting, DataHarmonizer compatible. Comes with valid and invalid data examples.

## Website

[https://turbomam.github.io/mixs-subset-examples-first](https://turbomam.github.io/mixs-subset-examples-first)

## Repository Structure

* [examples/](examples/) - example data
* [project/](project/) - project files (do not edit these)
* [src/](src/) - source files (edit these)
  * [mixs_subset_examples_first](src/mixs_subset_examples_first)
    * [schema](src/mixs_subset_examples_first/schema) -- LinkML schema
      (edit this)
    * [datamodel](src/mixs_subset_examples_first/datamodel) -- generated
      Python datamodel
* [tests/](tests/) - Python tests

## Developer Documentation

<details>
Use the `make` command to generate project artefacts:

* `make all`: make everything
* `make deploy`: deploys site
</details>

## Credits

This project was made with
[linkml-project-cookiecutter](https://github.com/linkml/linkml-project-cookiecutter).
