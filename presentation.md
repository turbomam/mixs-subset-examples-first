## clone repo

## install dependencies

## identify "worst offender" environmental packages
_ie environmental packages whose term definitions are the most contradictory compared to other environmental packages_

**provide background about why there are contradictions!**

The contradiction measure equals the average number of rows required to cover all definitions for a term when the rows defining terms from multiple packages are combined. 

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
- run worst_offenders on assets/mixs_combined_all.tsv to get an averages contradiction report `assets/worst_offender_averages.tsv`and a detailed contrdiction report `assets/worst_offender_details.tsv`

#### caveats: 
- The detailed report shows the degree of contradiction between pairs of environmental packages as raw scores
- The average/summary report uses 0-1 normalized scores
- The average/summary report also serves as a list of the environmental packages 
- The "environmental package" that appears as an empty string actually contains the term definitions for the MIxS checklists (like xxx and xxx) from the 

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