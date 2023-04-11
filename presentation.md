## clone repo

## install dependencies

## identify "worst offender" environmental packages
_ie environmental packages whose term definitions are the most contradictory compared to other environmental packages_

TODO: provide background about why there are contradictions!

```shell
make package_selection
```

from `project.Makefile`, which is included in the default `Makefile`

#### steps:
- comprehensive_cleanup (which includes a few other cleanup steps)
- curl -L "https://github.com/GenomicsStandardsConsortium/mixs/raw/mixs6.1.0/mixs/excel/mixs_v6.xlsx" > assets/mixs_v6.xlsx
- extract assets/mixs_v6_MIxS.tsv from the MIxS sheet in assets/mixs_v6.xlsx
- perform column removal and renaming on assets/mixs_v6.xlsx to get assets/mixs_v6_MIxS_managed_keys.tsv
- extract assets/mixs_v6_environmental_packages.tsv from the environmental_packages sheet in assets/mixs_v6.xlsx
- perform column removal and renaming on assets/mixs_v6_environmental_packages.tsv to get assets/mixs_v6_environmental_packages_managed_keys.tsv
- combine assets/mixs_v6_MIxS_managed_keys.tsv and assets/mixs_v6_environmental_packages_managed_keys.tsv, then reorder columns to get assets/mixs_combined_all.tsv
- run worst_offenders on assets/mixs_combined_all.tsv to get an averages contradiction report `assets/worst_offender_averages.tsv`and a detailed contradiction report `assets/worst_offender_details.tsv`

#### caveats: 
- The contradiction score equals the average number of unique rows per term definitions when multiple packages are combined. 
- The detailed report shows the degree of contradiction between pairs of environmental packages as raw scores
- The average/summary report uses 0-1 normalized scores
- The average/summary report also serves as a list of the environmental packages 
- The "environmental package" that appears as an empty string actually contains the term definitions for the MIxS checklists from the MIxS sheet

#### MIxS checklists
- migs_ba
- migs_eu
- migs_org
- migs_pl
- migs_vi
- mimag
- mimarks_c
- mimarks_s
- mims
- misag
- miuvig


| Environmental package                           | Normalized average contradiction |
|-------------------------------------------------|----------------------------------|
| built environment                               | 0.000                            |
| hydrocarbon resources-fluids/swabs              | 0.063                            |
| hydrocarbon resources-cores                     | 0.073                            |
| sediment                                        | 0.110                            |
| soil                                            | 0.113                            |
| wastewater/sludge                               | 0.113                            |
| microbial mat/biofilm                           | 0.114                            |
| miscellaneous natural or artificial environment | 0.126                            |
| water                                           | 0.139                            |
| air                                             | 0.155                            |
| human-vaginal                                   | 0.193                            |
| human-associated                                | 0.202                            |
| human-gut                                       | 0.206                            |
| human-skin                                      | 0.206                            |
| human-oral                                      | 0.213                            |
| plant-associated                                | 0.243                            |
|                                                 | 0.247                            |
| food-food production facility                   | 0.305                            |
| food-human foods                                | 0.354                            |
| host-associated                                 | 0.359                            |
| food-animal and animal feed                     | 0.459                            |
| agriculture                                     | 0.508                            |
| food-farm environment                           | 0.593                            |
| symbiont-associated                             | 1.000                            |

NMDC plans to support entry of most **environmental** environmental packages but currently emphasizes soil and water environments. Host associated packages are a lower priority at this time. Here we also include the "food-farm environment" package to demonstrate one that is introduces a higher level of contradiction.

| env1                  | env2                  | contradiction |
|-----------------------|-----------------------|---------------|
| food-farm environment | soil                  | 1.106         |
| food-farm environment | water                 | 1.071         |
| food-farm environment |                       | 1.049         |
| soil                  | food-farm environment | 1.106         |
| soil                  | water                 | 1.000         |
| soil                  |                       | 1.027         |
| water                 | food-farm environment | 1.071         |
| water                 | soil                  | 1.000         |
| water                 |                       | 1.023         |
|                       | food-farm environment | 1.049         |
|                       | soil                  | 1.027         |
|                       | water                 | 1.023         |

Experiment: try to resolve the contradictions between soil, water, food-farm environment (and the CChecklist terms)


configure the `assets/mixs_v6_environmental_packages_managed_keys_filtered.tsv` target in `project.Makefile` as follows:

```makefile
assets/mixs_v6_environmental_packages_managed_keys_filtered.tsv: assets/mixs_v6_environmental_packages_managed_keys.tsv
	$(RUN) filter_column \
		--input-tsv $< \
		--filter-column 'Environmental package' \
		--accepted-value soil \
		--accepted-value water \
		--accepted-value 'food-farm environment' \
		--accept-empties \
		--output-tsv $@
```

and run

```shell
make pre_modifications
```

- creates a `assets/mixs_combined_filtered.tsv` following steps analogous to those for `assets/mixs_combined_all.tsv` above
- creates some pre-modification reports that compare contradictions amongst term-identifying columns across the selected environmental packages 
  - these are considered pre-modification reports because the next recommended step is modifying teh term definitions to eliminate contradictions. After that, post modification reports can be run.
  - reports have not been generated or shown below for illustrating all contradictions in all attributes of the term definitions 

#### assets/report_pre_id_item_multi_pairings.out
- MIXS ID value: MIXS:0000643 is paired with multiple values in Item: {'mean seasonal air temperature', '**mean seasonal temperature**'}
- _MIXS ID value: MIXS:0000103 is paired with multiple values in Item: {'spike-in organism count', 'organism count'}_

#### assets/report_pre_id_scn_multi_pairings.out
- MIXS ID value: MIXS:0000002 is paired with multiple values in Structured comment name: {'**samp_collect_device**', 'samp_collec_device'}
- _MIXS ID value: MIXS:0000103 is paired with multiple values in Structured comment name: {'organism_count', 'spikein_count'}_
- MIXS ID value: MIXS:0000116 is paired with multiple values in Structured comment name: {'samp_stor_dur', '**samp_store_dur**'}
- MIXS ID value: MIXS:0000110 is paired with multiple values in Structured comment name: {'samp_stor_temp', '**samp_store_temp**'}

#### assets/report_pre_sc_item_multi_pairings.out
- Structured comment name value: season_temp is paired with multiple values in Item: {'mean seasonal air temperature', '**mean seasonal temperature**'}
- Item value: sample collection device is paired with multiple values in Structured comment name: {'samp_collec_device', '**samp_collect_device**'}
- Item value: sample storage duration is paired with multiple values in Structured comment name: {'**samp_store_dur**', 'samp_stor_dur'}
- Item value: sample storage temperature is paired with multiple values in Structured comment name: {'samp_stor_temp', '**samp_store_temp**'}

The bolded values above were selected in consultation with https://www.ncbi.nlm.nih.gov/biosample/docs/attributes/. NMDC does not consider that records from NCBI or any other INSDC member should be taken as definitions of MIxS terms, but they do provide a useful record of how terms have been used in the past. Note that https://www.ncbi.nlm.nih.gov/biosample/docs/attributes/ does not provide MIxS IDs for the attributes 

https://www.ncbi.nlm.nih.gov/biosample/docs/attributes/ does provide definitions for both _'organism_count'_ and _'spikein_count_'. We can run the following code on the unfiltered `mixs_combined_all.tsv` from above in an attempt to resolve the contradictions.


```shell
poetry run filter_column \
	--input-tsv keep/mixs_combined_all.tsv \
	--filter-column 'Structured comment name' \
	--accepted-value spikein_count \
	--accepted-value organism_count \
	--no-accept-empties \
	--output-tsv assets/spikein_vs_org_count.tsv
```

| MIXS ID      | Structured comment name | Item                    | Environmental package                           |
|--------------|-------------------------|-------------------------|-------------------------------------------------|
| MIXS:0000103 | organism_count          | organism count          | agriculture                                     |
| MIXS:0000103 | organism_count          | organism count          | air                                             |
| MIXS:0000103 | organism_count          | organism count          | built environment                               |
| MIXS:0000103 | organism_count          | organism count          | food-animal and animal feed                     |
| MIXS:0000103 | organism_count          | organism count          | food-farm environment                           |
| MIXS:0000103 | organism_count          | organism count          | food-food production facility                   |
| MIXS:0000103 | organism_count          | organism count          | food-human foods                                |
| MIXS:0000103 | organism_count          | organism count          | host-associated                                 |
| MIXS:0000103 | organism_count          | organism count          | human-associated                                |
| MIXS:0000103 | organism_count          | organism count          | human-gut                                       |
| MIXS:0000103 | organism_count          | organism count          | human-oral                                      |
| MIXS:0000103 | organism_count          | organism count          | human-skin                                      |
| MIXS:0000103 | organism_count          | organism count          | human-vaginal                                   |
| MIXS:0000103 | organism_count          | organism count          | hydrocarbon resources-cores                     |
| MIXS:0000103 | organism_count          | organism count          | hydrocarbon resources-fluids/swabs              |
| MIXS:0000103 | organism_count          | organism count          | microbial mat/biofilm                           |
| MIXS:0000103 | organism_count          | organism count          | miscellaneous natural or artificial environment |
| MIXS:0000103 | organism_count          | organism count          | plant-associated                                |
| MIXS:0000103 | organism_count          | organism count          | sediment                                        |
| MIXS:0000103 | organism_count          | organism count          | symbiont-associated                             |
| MIXS:0000103 | organism_count          | organism count          | wastewater/sludge                               |
| MIXS:0000103 | organism_count          | organism count          | water                                           |
| MIXS:0000103 | spikein_count           | spike-in organism count | food-animal and animal feed                     |
| MIXS:0000103 | spikein_count           | spike-in organism count | food-farm environment                           |
| MIXS:0001335 | spikein_count           | spike-in organism count | food-human foods                                |

And also

```shell
poetry run filter_column \
	--input-tsv keep/mixs_combined_all.tsv \
	--filter-column 'MIXS ID' \
	--accepted-value 'MIXS:0000103' \
	--accepted-value 'MIXS:0001335' \
	--no-accept-empties \
	--output-tsv assets/0000103_vs_0001335_by_ID.tsv
```

| MIXS ID      | Structured comment name | Item                    | Environmental package                           |
|--------------|-------------------------|-------------------------|-------------------------------------------------|
| MIXS:0000103 | organism_count          | organism count          | air                                             |
| MIXS:0000103 | organism_count          | organism count          | built environment                               |
| MIXS:0000103 | organism_count          | organism count          | host-associated                                 |
| MIXS:0000103 | organism_count          | organism count          | human-associated                                |
| MIXS:0000103 | organism_count          | organism count          | human-gut                                       |
| MIXS:0000103 | organism_count          | organism count          | human-oral                                      |
| MIXS:0000103 | organism_count          | organism count          | human-skin                                      |
| MIXS:0000103 | organism_count          | organism count          | human-vaginal                                   |
| MIXS:0000103 | organism_count          | organism count          | hydrocarbon resources-cores                     |
| MIXS:0000103 | organism_count          | organism count          | hydrocarbon resources-fluids/swabs              |
| MIXS:0000103 | organism_count          | organism count          | microbial mat/biofilm                           |
| MIXS:0000103 | organism_count          | organism count          | miscellaneous natural or artificial environment |
| MIXS:0000103 | organism_count          | organism count          | plant-associated                                |
| MIXS:0000103 | organism_count          | organism count          | sediment                                        |
| MIXS:0000103 | organism_count          | organism count          | wastewater/sludge                               |
| MIXS:0000103 | organism_count          | organism count          | water                                           |
| MIXS:0000103 | organism_count          | organism count          | symbiont-associated                             |
| MIXS:0000103 | organism_count          | organism count          | food-human foods                                |
| MIXS:0000103 | organism_count          | organism count          | food-animal and animal feed                     |
| MIXS:0000103 | organism_count          | organism count          | food-food production facility                   |
| MIXS:0000103 | organism_count          | organism count          | food-farm environment                           |
| MIXS:0000103 | organism_count          | organism count          | agriculture                                     |
| MIXS:0000103 | spikein_count           | spike-in organism count | food-animal and animal feed                     |
| MIXS:0000103 | spikein_count           | spike-in organism count | food-farm environment                           |
| MIXS:0001335 | spikein_count           | spike-in organism count | food-human foods                                |

Conclusion: 
- MIXS:0001335 is only ever used for spikein_count
- MIXS:0000103 is almost always used for organism_count

We can now create assets/mixs_combined_filtered_modified.tsv by copying assets/mixs_combined_filtered.tsv and overwrite all contradictory 'MIXS ID's, 'Structured comment name's and 'Item's with their consensus values

_Not shown: the values that needed to be edited to resolve contradictions almost all came from the 'food-farm environment' package_

```shell
make post_modifications
```

At this point, all of the `assets/report_post_*_multi_pairings.out` files show that there are not contradictions in the 'MIXS ID', 'Structured comment name' and 'Item' columns when comparing the selected environmental packages. There are contradictions however in other columns. See assets/mixs_conflicting_terms.tsv
and assets/mixs_uniform_terms.tsv.  

It would also be possible to create more reports with `find_multi_pairings`. These should use the "MIXS ID" as one of the keys, since they were normalized in the steps described above. However, some columns aren't meaningful comparators. "Environmental package" and "Section" aren't really part of the term definitions. It might be reasonable to leave some term attributes as variable (or contradictory), For example, the examples for a term might reasonably be different from one environmental apackage to another. Other term attributes are more a matter of judgement: is it semantically reasonable for the Definition to vary from one class to another? Finally, there are some term attributes that can not be verbalizable for technical reasons relating to storage. A slot can not have Occurrence of '1' for some classes and 'm' for others. THis patterns become more apparent when the term attributes are mapped to LinkML slot attributes as cataloged below:

_Goal: monotonicity at a minimum. A class can use a term in a way that is more conservative than the usage in other classes, as long as it is otherwise compatible. This is not yet enforced or even warned in LinkML yet._

- MIXS ID
  - primary key/LinkML slot_url (or class_url)
  - needs prefix expansion in schema
  - needs w3id resolver
- Structured comment name
  - LinkML name
  - invariant across all packages and checklists
    - names can undergo normalization in derived artifacts like RDF, JSON schema, etc.
    - Allow 'Structured comment name' to start with characters other than [a-zA-z]? 
      - 16s_recover
      - 16s_recover_software
    - Allow delimiters other than _ in 'Structured comment name's?
      - associated resource
- Item
  - LinkML title
  - Allow variable 'Item' values, ie LinkML titles?
- Environmental package
  - model as LinkML classes?
  - where can we find authoritative, structure metadata like id, description,
- Section
  - These come from the MIxS sheet. Note the absence of "core", which was introduced by https://github.com/GenomicsStandardsConsortium/mixs/blob/main/gsctools/mixs_converter.py
  - model as LinkML slot_groups?
  - where can we find authoritative, structured metadata?
- Expected value
  - combination of content that can be interpreted as LinkML range, ontological roots of enumerations (using inconsistent notation), inconsistent pattern hints, and free-form narratives
  - Range is invariant. The other content could possibly be routed into slot attributes that could tolerate variance/contradiction
- Value syntax
  - hints about LinkML patterns/structured patterns (with inconsistent grammar), conventional enumerations, and enum/pattern hybrids
  - patterns can tolerate variance/contradiction. enums can also tolerate variance/contradiction by way of creating multiple enums
- Occurrence
  - LinkML `multivalued`
  - Invariant
- Preferred unit
  - unit designations are new to LinkML. Unsure.
- Example
  - variance/contradiction allowed
  - break out implicit lists into explicit lists
  - implicit list delimiters may not be consistent
- Definition
  - separate out LinkML `description` from content that should go in other attributes, like examples, patterns, ontological roots of enums, etc.


See also https://linkml.io/linkml-model/docs/SlotDefinition/

_Note: slot/class requirement is expressed in a wide fashion (by checklist) in the MIxS shet and in a long fashion (by environmental_package) in the environmental_packages sheet. These are not propagated to files like assets/mixs_combined_all.tsv, assets/mixs_combined_filtered.tsv, assets/mixs_combined_filtered_modified.tsv_ 

Omitted requirement-like attributes 
- from the MIxS sheet: just the checklist columns
- from the environmental package sheet: just the Requirement column

~~Let's take the example here of changing the name of the "MIXS ID" column to "slot_uri" and generating another multi-pairing/contradiction report.~~

~~Note: The list of term attributes above mentions the need for splitting an attribute into multiple LinkML slot attributes. An analogous activity is checking potentially contradictory attributes of a term, like an "Expected value" that contains an examples that doesn't match the "Value syntax"~~

consistent column names are required for the generation of assets/mixs_combined_diff.html, which has system requirement of https://github.com/aswinkarthik/csvdiff

TODO: normalize the use of contradiction, variable and multi-pairing in script names and documentation

TODO: alphabetize find_multi_pairings results by key

```shell
poetry run find_multi_pairings \
	--column_a "MIXS ID" \
	--column_b "Expected value" \
	--input_tsv assets/mixs_combined_filtered_modified.tsv \
	--report_by column_a
```

- MIXS ID value: MIXS:0000092 is paired with multiple values in Expected value: {'', 'text'}
- MIXS ID value: MIXS:0000012 is paired with multiple values in Expected value: {'The major environment type(s) where the sample was collected. Recommend subclasses of biome [ENVO:00000428]. Multiple terms can be separated by one or more pipes.', 'Add terms that identify the major environment type(s) where your sample was collected. Recommend subclasses of biome [ENVO:00000428]. Multiple terms can be separated by one or more pipes e.g.: mangrove biome [ENVO:01000181]|estuarine biome [ENVO:01000020]'}
- MIXS ID value: MIXS:0000013 is paired with multiple values in Expected value: {'Environmental entities having causal influences upon the entity at time of sampling.', 'Add terms that identify environmental entities having causal influences upon the entity at time of sampling, multiple terms can be separated by pipes, e.g.: shoreline [ENVO:00000486]|intertidal zone [ENVO:00000316]'}
- MIXS ID value: MIXS:0000014 is paired with multiple values in Expected value: {'Add terms that identify the material displaced by the entity at time of sampling. Recommend subclasses of environmental material [ENVO:00010483]. Multiple terms can be separated by pipes e.g.: estuarine water [ENVO:01000301]|estuarine mud [ENVO:00002160]', 'The material displaced by the entity at time of sampling. Recommend subclasses of environmental material [ENVO:00010483]. '}
- MIXS ID value: MIXS:0000533 is paired with multiple values in Expected value: {'percent TOC', 'measurement value'}
- MIXS ID value: MIXS:0000752 is paired with multiple values in Expected value: {'parameter name;measurement value', 'parameter name; measurement value'}
- MIXS ID value: MIXS:0000103 is paired with multiple values in Expected value: {'organism name; measurement value; enumeration', 'organism name;measurement value;enumeration'}


Note that some contradictions may be very subtle, like a missing whitespace character. It is most important to identify contradictions within the definition of individual terms, but it can also be helpful to start normalizing patters like this across terms. For example: is whitespace required after semicolons? Are period characters (.) required at the end of sentence-like values? Global find and replace can be helpful here.

Other constrictions require more deliberation. FOr example, these two definitions for MIXS:0000183:
- Salinity is the total concentration of all dissolved salts in a water sample. While salinity can be measured by a complete chemical analysis, this method is difficult and time consuming. More often, it is instead derived from the conductivity measurement. This is known as practical salinity. These derivations compare the specific conductance of the sample to a salinity standard such as seawater
- The total concentration of all dissolved salts in a liquid or solid sample. While salinity can be measured by a complete chemical analysis, this method is difficult and time consuming. More often, it is instead derived from the conductivity measurement. This is known as practical salinity. These derivations compare the specific conductance of the sample to a salinity standard such as seawater.

A definition does not need to mention the term, so "Salinity is" is removed. Since the two definitions don't agree about whether the sample should be water, liquid or solid, that distinction is removed.

> The total concentration of all dissolved salts in a sample. While salinity can be measured by a complete chemical analysis, this method is difficult and time-consuming. More often, it is instead derived from the conductivity measurement. This is known as practical salinity. These derivations compare the specific conductance of the sample to a salinity standard such as seawater. 

Don't forget to check grammar, spelling, etc.

----



#### Enum/PV considerations:
- collapse enums
- be careful with PV names
- provide meanings

Show noisiness of NCBI Biosamples for MIxS terms

Can delete rows that are not attributed to any environmental package and are not associated with any desired checklist in the MIxS sheet?

