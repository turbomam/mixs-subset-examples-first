## Add your own custom Makefile targets here

RUN = poetry run

.PHONY: check-jsonschema-example run-linkml-validation

#check-jsonschema-example: project/jsonschema/mixs_subset_examples_first.schema.json \
#	  src/data/examples/invalid/BiosampleCollection-undefined-slot.yaml
#	# showing ignore failures here
#	# this should be templated
#	- $(RUN) check-jsonschema \
#	  --schemafile $^
#
#run-linkml-validation: src/mixs_subset_examples_first/schema/mixs_subset_examples_first.yaml \
#src/data/examples/invalid/BiosampleCollection-undefined-slot.yaml
#	# PersonCollection is assumed as the target-class because it has been defined as the tree_root in the schema
#	- $(RUN) linkml-validate \
#	  --schema $^


#src/data/dh_vs_linkml_json/BiosampleCollection_linkml_raw.yaml: src/data/dh_vs_linkml_json/Biosample_dh.json
#	$(RUN) dh-json2linkml \
#		--input-file $< \
#		--output-file $@ \
#		--output-format yaml \
#		--key entries
#
#
#src/data/dh_vs_linkml_json/BiosampleCollection_linkml_normalized.yaml: src/data/dh_vs_linkml_json/BiosampleCollection_linkml_raw.yaml
#	$(RUN) linkml-normalize \
#		--schema src/mixs_subset_examples_first/schema/mixs_subset_examples_first.yaml \
#		--output $@ \
#		--no-expand-all $<
#
#src/data/dh_vs_linkml_json/entries.json: src/data/dh_vs_linkml_json/BiosampleCollection_linkml_normalized.yaml
#	$(RUN) linkml-json2dh \
#		--input-file $< \
#		--input-format yaml \
#		--output-dir $(dir $@)

#project/reports/slot_usage_esp_validation.tsv:
#	linkml2sheets \
#		--schema src/mixs_subset_examples_first/schema/mixs_subset_examples_first.yaml \
#		--output $@ \
#		src/local_schemasheets/templates/slot_usage_esp_validation.tsv

###   ###   ###

# Define a list of sheet names to extract.
SHEET_NAMES := MIxS environmental_packages

.PHONY: proj_clean report_contradiction_scores extract_all_sheets column_alignment_all \
modification_lifecycle \
post_column_alignment_diff_report pre_column_alignment_diff_report \
pre_modifications report_id_item_contradictions report_id_scn_contradictions report_sc_item_contradictions tsvs_cleanup

proj_clean: target_cleanup downloads_cleanup reports_cleanup data_cleanup
	rm -rf data/codified_env_package_requirements.tsv
	rm -rf data/mixs_v6_environmental_packages.tsv
	rm -rf docs
	rm -rf project
	rm -rf project/mixs_v6_env_packages_checklists_classes.schema.json
	rm -rf site
	rm -rf src/mixs_subset_examples_first/datamodel/mixs_subset_examples_first.py
	rm -rf src/mixs_subset_examples_first/schema/*.yaml*
	rm -rf src/mixs_subset_examples_first/schema/mixs_subset_examples_first.yaml
	rm -rf src/mixs_subset_examples_first/schema/mixs_subset_examples_first_materialized_patterns.yaml
	rm -rf reports/mixs_subset_examples_first_materialized_patterns.yaml.linting.tsv
	mkdir -p docs
	mkdir -p project
	mkdir -p site
	mkdir -p src/mixs_subset_examples_first/schema
	touch docs/.gitkeep
	touch project/.gitkeep
	touch site/.gitkeep
	touch src/mixs_subset_examples_first/datamodel/mixs_subset_examples_first.py
	touch src/mixs_subset_examples_first/schema/.gitkeep


report_contradiction_scores: proj_clean reports/contradiction_score_details.tsv

reports/contradiction_score_details.tsv: data/mixs_combined_all.tsv
	$(RUN) contradiction_score_reports \
		--summary-report-tsv $(subst details,summary,$@) \
		--details-report-tsv $@ \
		--excluded-cols "Environmental package" \
		--excluded-cols "Example" \
		--excluded-cols "Preferred unit" \
		--excluded-cols "Section" \
		--input-tsv $<

pre_modifications_reports: proj_clean extract_all_sheets \
reports/pre_column_alignment_diff_report.yaml column_alignment_all reports/post_column_alignment_diff_report.yaml \
target/mixs_combined_filtered.tsv \
reports/report_pre_id_scn_contradictions.yaml

# target/report_pre_sc_item_contradictions.out target/report_pre_id_item_contradictions.out

post_modifications: reports/report_post_id_scn_contradictions.yaml \
target/mixs_uniform_terms.tsv \
target/mixs_combined_diff.html

target_cleanup:
	rm -rf target
	mkdir -p target
	touch target/.gitkeep

downloads_cleanup:
	rm -rf downloads
	mkdir -p downloads
	touch downloads/.gitkeep

reports_cleanup:
#	rm -rf downloads
	mkdir -p reports
	touch reports/.gitkeep
	rm -rf reports/report_pre_*_contradictions.yaml
	rm -rf reports/report_post_*_contradictions.yaml
	rm -rf reports/Database-mimssoil_set-example.yaml.check-jsonschema.log

data_cleanup:
#	rm -rf downloads
	mkdir -p data
	touch data/.gitkeep
	rm -rf data/core_requirements.tsv
	rm -rf data/mixs_v6_asserted_and_combinations.tsv
	rm -rf data/mixs_v6_checklists_env_packages_combination_classes.tsv
	rm -rf data/mixs_v6_env_packages_checklists_classes.schema.json
	rm -rf data/mixs_v6_env_packages_checklists_classes.yaml



#comprehensive_cleanup: tsvs_cleanup column_alignment_cleanup diff_cleanup
#	rm -rf \
#target/drop_then_remove_dupes.out \
#target/mixs_combined_conservative.tsv \
#target/mixs_combined_diff_conservative.html \
#target/mixs_combined_original.tsv \
#target/mixs_conflicting_terms.tsv \
#target/mixs_uniform_terms.tsv \
#reports/post_column_alignment_diff_report.out \
#reports/pre_column_alignment_diff_report.yaml \
#target/report_id_item_contradictions.out \
#target/report_id_scn_contradictions.out \
#target/report_post_id_item_contradictions.out \
#target/report_post_id_scn_contradictions.out \
#target/report_post_sc_item_contradictions.out \
#target/report_pre_id_item_contradictions.out \
#reports/report_pre_id_scn_contradictions.yaml \
#target/report_pre_sc_item_contradictions.out \
#target/report_post_id_item_scn_contradictions.out


diff_cleanup:
	rm -rf target/mixs_combined_no_752.tsv target/mixs_combined_modified_no_752.tsv target/mixs_combined_diff.html

column_alignment_cleanup:
	rm -rf data/mixs_v6_MIxS_aligned_cols.tsv data/mixs_v6_environmental_packages_aligned_cols.tsv target/mixs_v6_environmental_packages_aligned_cols_filtered.tsv

tsvs_cleanup:
	rm -rf \
target/mixs_combined.tsv \
data/mixs_combined_all.tsv \
target/mixs_combined_filtered.tsv \
downloads/mixs_v6.xlsx \
data/mixs_v6_MIxS.tsv \
data/mixs_v6_MIxS_aligned_cols.tsv \
data/mixs_v6_environmental_packages.tsv \
data/mixs_v6_environmental_packages_aligned_cols.tsv \
target/mixs_v6_environmental_packages_aligned_cols_filtered.tsv \
target/*tsv

## Chris Mungall and Chris Hunter prefer not to the MIxS Google Sheets in
##   https://docs.google.com/spreadsheets/d/1QDeeUcDqXes69Y2RjU2aWgOpCVWo5OVsBX9MKmMqi_o
##   - They have already been converted into Mungall's https://github.com/GenomicsStandardsConsortium/mixs/tree/main/model/schema by mixs_converter.py
##   - They could have theoretically been changed since the MIxS 6.1 release was made

downloads/mixs_v6.xlsx:
	curl -L "https://github.com/GenomicsStandardsConsortium/mixs/raw/mixs6.1.0/mixs/excel/mixs_v6.xlsx" > $@

reports/pre_column_alignment_diff_report.yaml: data/mixs_v6_MIxS.tsv data/mixs_v6_environmental_packages.tsv
	$(RUN) compare_headers \
		--file1 $(word 1, $^) \
		--file2  $(word 2, $^) \
		--output-yaml $@


# Define a pattern rule to generate TSV files for all sheets in the XLSX file.
data/mixs_v6_%.tsv: downloads/mixs_v6.xlsx
	$(RUN) xlsx_tab_to_tsv \
		--log_level INFO \
		--sheet $* \
		--tsv_output $@ \
		--xlsx_input $<

extract_all_sheets: downloads/mixs_v6.xlsx $(patsubst %,data/mixs_v6_%.tsv,$(SHEET_NAMES))

data/mixs_v6_MIxS_aligned_cols.tsv: data/mixs_v6_MIxS.tsv
	$(RUN) tsv_column_alignment \
		--input-tsv $< \
		--output-tsv $@ \
		--column-to-remove migs_ba \
		--column-to-remove migs_eu \
		--column-to-remove migs_org \
		--column-to-remove migs_pl \
		--column-to-remove migs_vi \
		--column-to-remove mimag \
		--column-to-remove mimarks_c \
		--column-to-remove mimarks_s \
		--column-to-remove mims \
		--column-to-remove misag \
		--column-to-remove miuvig \
		--rename-column "Item (rdfs:label)" Item \
		--rename-column Occurence Occurrence

data/mixs_v6_environmental_packages_aligned_cols.tsv: data/mixs_v6_environmental_packages.tsv
	$(RUN) tsv_column_alignment \
		--input-tsv $< \
		--output-tsv $@ \
		--column-to-remove Requirement \
		--rename-column "Package item" Item

column_alignment_all: column_alignment_cleanup data/mixs_v6_MIxS_aligned_cols.tsv target/mixs_v6_environmental_packages_aligned_cols_filtered.tsv


target/mixs_v6_environmental_packages_aligned_cols_filtered.tsv: data/mixs_v6_environmental_packages_aligned_cols.tsv
	$(RUN) filter_column \
		--input-tsv $< \
		--filter-column 'Environmental package' \
		--accepted-value soil \
		--accepted-value water \
		--accepted-value 'food-farm environment' \
		--accept-empties \
		--output-tsv $@

reports/post_column_alignment_diff_report.yaml: data/mixs_v6_MIxS_aligned_cols.tsv target/mixs_v6_environmental_packages_aligned_cols_filtered.tsv
	$(RUN) compare_headers \
		--file1 $(word 1, $^) \
		--file2  $(word 2, $^) \
		--output-yaml $@

data/mixs_combined_all.tsv: data/mixs_v6_MIxS_aligned_cols.tsv data/mixs_v6_environmental_packages_aligned_cols.tsv
	$(RUN) combine_any_tsvs \
	  --input-tsv1 $(word 1, $^) \
	  --input-tsv2 $(word 2, $^) \
	  --column-order "MIXS ID","Structured comment name","Item","Environmental package","Section","Expected value","Value syntax","Occurrence","Preferred unit","Example","Definition" \
	  --output-tsv $@


target/mixs_combined_filtered.tsv: data/mixs_v6_MIxS_aligned_cols.tsv target/mixs_v6_environmental_packages_aligned_cols_filtered.tsv
	$(RUN) combine_any_tsvs \
	  --input-tsv1 $(word 1, $^) \
	  --input-tsv2 $(word 2, $^) \
	  --column-order "MIXS ID","Structured comment name","Item","Environmental package","Section","Expected value","Value syntax","Occurrence","Preferred unit","Example","Definition" \
	  --output-tsv $@

#target/mixs_combined_filtered.tsv
reports/report_pre_id_scn_contradictions.yaml: data/mixs_combined_all.tsv data/ncbi_biosample_attributes.xml
	$(RUN) find_contradictions \
		--attributes-file $(word 2, $^) \
		--attributes-key HarmonizedName \
		--context "Environmental package" \
		--input-file $< \
		--key1 "MIXS ID" \
		--key2 "Structured comment name" \
		--output-file $@

####


do_post_reports: clean_reports \
reports/report_post_id_scn_contradictions.yaml \
reports/report_post_id_item_contradictions.yaml \
reports/report_post_id_occurrence_contradictions.yaml \
reports/report_post_id_prefunit_contradictions.yaml \
reports/report_post_id_example_contradictions.yaml \
reports/report_post_id_description_contradictions.yaml

clean_reports:
	rm -rf reports/report_post_*_contradictions.yaml
	rm -rf reports/Database-mimssoil_set-example.yaml.check-jsonschema.log

reports/report_post_id_scn_contradictions.yaml: data/mixs_combined_all_modified.tsv data/ncbi_biosample_attributes.xml
	$(RUN) find_contradictions \
		--attributes-file $(word 2, $^) \
		--attributes-key HarmonizedName \
		--context "Environmental package" \
		--input-file $< \
		--key1 "MIXS ID" \
		--key2 "Structured comment name" \
		--output-file $@

reports/report_post_id_item_contradictions.yaml: data/mixs_combined_all_modified.tsv data/ncbi_biosample_attributes.xml
	$(RUN) find_contradictions \
		--attributes-file $(word 2, $^) \
		--attributes-key Name \
		--context "Environmental package" \
		--input-file $< \
		--key1 "MIXS ID" \
		--key2 "Item" \
		--output-file $@

reports/report_post_id_occurrence_contradictions.yaml: data/mixs_combined_all_modified.tsv data/ncbi_biosample_attributes.xml
	$(RUN) find_contradictions \
		--attributes-file $(word 2, $^) \
		--attributes-key Name \
		--context "Environmental package" \
		--input-file $< \
		--key1 "MIXS ID" \
		--key2 "Occurrence" \
		--no-check-ncbi \
		--no-see-alsos \
		--output-file $@

reports/report_post_id_prefunit_contradictions.yaml: data/mixs_combined_all_modified.tsv data/ncbi_biosample_attributes.xml
	$(RUN) find_contradictions \
		--attributes-file $(word 2, $^) \
		--attributes-key Name \
		--context "Environmental package" \
		--input-file $< \
		--key1 "MIXS ID" \
		--key2 "Preferred unit" \
		--no-check-ncbi \
		--no-see-alsos \
		--output-file $@

reports/report_post_id_example_contradictions.yaml: data/mixs_combined_all_modified.tsv data/ncbi_biosample_attributes.xml
	$(RUN) find_contradictions \
		--attributes-file $(word 2, $^) \
		--attributes-key Name \
		--context "Environmental package" \
		--input-file $< \
		--key1 "MIXS ID" \
		--key2 "Example" \
		--no-check-ncbi \
		--no-see-alsos \
		--output-file $@

reports/report_post_id_description_contradictions.yaml: data/mixs_combined_all_modified.tsv data/ncbi_biosample_attributes.xml
	$(RUN) find_contradictions \
		--attributes-file $(word 2, $^) \
		--attributes-key Description \
		--context "Environmental package" \
		--input-file $< \
		--key1 "MIXS ID" \
		--key2 "Definition" \
		--output-file $@


reports/report_post_id_valsyn_contradictions.yaml: data/mixs_combined_all_modified.tsv data/ncbi_biosample_attributes.xml
	$(RUN) find_contradictions \
		--attributes-file $(word 2, $^) \
		--attributes-key Description \
		--context "Environmental package" \
		--input-file $< \
		--key1 "MIXS ID" \
		--key2 "Value syntax" \
		--no-check-ncbi \
		--no-see-alsos \
		--output-file $@


reports/report_post_id_expval_contradictions.yaml: data/mixs_combined_all_modified.tsv data/ncbi_biosample_attributes.xml
	$(RUN) find_contradictions \
		--attributes-file $(word 2, $^) \
		--attributes-key Description \
		--context "Environmental package" \
		--input-file $< \
		--key1 "MIXS ID" \
		--key2 "Expected value" \
		--no-check-ncbi \
		--no-see-alsos \
		--output-file $@


reports/report_post_id_range_contradictions.yaml: data/mixs_combined_all_modified.tsv data/ncbi_biosample_attributes.xml
	$(RUN) find_contradictions \
		--attributes-file $(word 2, $^) \
		--attributes-key Description \
		--context "Environmental package" \
		--input-file $< \
		--key1 "MIXS ID" \
		--key2 "range" \
		--no-check-ncbi \
		--no-see-alsos \
		--output-file $@


reports/report_post_id_strucpat_contradictions.yaml: data/mixs_combined_all_modified.tsv data/ncbi_biosample_attributes.xml
	$(RUN) find_contradictions \
		--attributes-file $(word 2, $^) \
		--attributes-key Description \
		--context "Environmental package" \
		--input-file $< \
		--key1 "MIXS ID" \
		--key2 "structured pattern" \
		--no-check-ncbi \
		--no-see-alsos \
		--output-file $@

data/ncbi_biosample_attributes.xml:
	curl -o $@ https://www.ncbi.nlm.nih.gov/biosample/docs/attributes/?format=xml

#target/report_pre_sc_item_contradictions.out: target/mixs_combined_filtered.tsv
#	$(RUN) find_contradictions \
#		--input_tsv $< \
#		--column_a "Structured comment name" \
#		--column_b "Item" | tee $@
#
#target/report_pre_id_item_contradictions.out: target/mixs_combined_filtered.tsv
#	$(RUN) find_contradictions \
#		--input_tsv $< \
#		--column_a "MIXS ID" \
#		--column_b "Item" | tee $@
#
#
#target/report_post_id_scn_contradictions.out: target/mixs_combined_filtered_modified.tsv
#	$(RUN) find_contradictions \
#		--input_tsv $< \
#		--column_a "MIXS ID" \
#		--column_b "Structured comment name" | tee $@
#
#target/report_post_sc_item_contradictions.out: target/mixs_combined_filtered_modified.tsv
#	$(RUN) find_contradictions \
#		--input_tsv $< \
#		--column_a "Structured comment name" \
#		--column_b "Item" | tee $@
#
#target/report_post_id_item_contradictions.out: target/mixs_combined_filtered_modified.tsv
#	$(RUN) find_contradictions \
#		--input_tsv $< \
#		--column_a "MIXS ID" \
#		--column_b "Item" | tee $@


## WHICH COLUMNS TO DROP?
# denoters
  #MIXS ID
  #Structured comment name
  #Item

# context
  #Environmental package
  #Section

  #Expected value
  #Value syntax
  #Occurrence
  #Preferred unit
  #Definition

# package specific
  #Example

target/mixs_uniform_terms.tsv: target/mixs_combined_filtered_modified.tsv
	$(RUN) drop_then_remove_dupes \
		--input-tsv $< \
		--uniform-terms-out $@ \
		--conflicting-terms-out $(subst uniform,conflicting, $@) \
		--drop-field "Environmental package" \
		--drop-field "Section" \
		--drop-field "Example" | tee target/drop_then_remove_dupes.out

## comparing some rows crashes csvdiff
## todo: don't foget to specify which csvdiff we're using
#target/mixs_combined_conservative.tsv: target/mixs_combined_filtered.tsv
#	grep -v "MIXS:0000752" $< | \
#	grep -v "MIXS:0000755" | \
#	grep -v "MIXS:0001230" > $@
#
#target/mixs_combined_modified_conservative.tsv: target/mixs_combined_modified.tsv
#	grep -v "MIXS:0000752" $< | \
#	grep -v "MIXS:0000755" | \
#	grep -v "MIXS:0001230" > $@

# this may not work on Macs
# ie may only work on Linux esp Ubuntu
target/mixs_combined_diff.html: target/mixs_combined_filtered.tsv target/mixs_combined_filtered_modified.tsv
	script -q -c "csvdiff --separator '\t'  --primary-key 0,3,4 --format word-diff  $^" | aha > $@


target/spikein_vs_org_count_by_scn.tsv: data/mixs_combined_all.tsv
	$(RUN) filter_column \
		--input-tsv $< \
		--filter-column 'Structured comment name' \
		--accepted-value spikein_count \
		--accepted-value organism_count \
		--accept-empties \
		--output-tsv $@


target/0000103_vs_0001335_by_ID.tsv: data/mixs_combined_all.tsv
	$(RUN) filter_column \
		--input-tsv $< \
		--filter-column 'MIXS ID' \
		--accepted-value 'MIXS:0000103' \
		--accepted-value 'MIXS:0001335' \
		--accept-empties \
		--output-tsv $@

####

data/mixs_v6_environmental_packages_for_classes.tsv: data/mixs_v6_environmental_packages.tsv
	$(RUN) extract_unique_column_vals \
		--input-tsv $< \
		--output-tsv $@ \
		--column "Environmental package"

data/mixs_v6_checklists_plus_for_classes.tsv: data/mixs_v6_MIxS.tsv
	$(RUN) headers_as_lines \
		--input-tsv $< \
		--output-tsv $@

# creation of data/mixs_v6_checklists_env_packages_classes_curated.tsv
# concatenate:
#   from data/mixs_v6_checklists_plus_for_classes.tsv: migs_ba migs_eu migs_org migs_pl migs_vi mimag mimarks_c mimarks_s mims misag miuvig
#   from data/mixs_v6_environmental_packages_for_classes.tsv: ALL ROWS
# add the following two rows of tab-separated headers
#class title  aliases    class_uri  description    in_subset  is_a   mixin  mixins
#> class   title  aliases    class_uri  description    in_subset  is_a   mixin  mixins
# add rows with the following two class names:
#Checklist
#EnvironmentalPackage
# and assign those as the is_a parent to the rows from data/mixs_v6_environmental_packages_for_classes.tsv and data/mixs_v6_checklists_plus_for_classes.tsv
# the mixin column for the checklist rows should be set to true
#   Excel "TRUE" or "'true"?
# sort by G (is_a) and then A (class) without sorting the two header rows
# add class_uri values (from where?)
#   this source is a cheat because I extracted it from some file LS shared with me
#     https://github.com/GenomicsStandardsConsortium/mixs/blob/issue-511-tested-schemasheets/schemasheets/tsv_in/MIxS_6_term_updates_classdefs.tsv
# I don't see any term with ID MIXS:0016017
#   could create an UnknownTerm class as a placeholder
# Does this need to be added manually?
#   Agriculture    agriculture       MIXS:0016018
# add description values (from where?)

# creation of data/mixs_v6_checklists_env_packages_combination_classes_curated.tsv
# just pick a small subset of combination rows


data/mixs_v6_checklists_env_packages_combination_classes.tsv:
	# assumes the curated file has two header rows
	$(RUN) combine_checklists_and_env_packages \
		--input-file data/mixs_v6_checklists_env_packages_classes_curated.tsv \
		--output-file $@ \

data/mixs_v6_asserted_and_combinations.tsv:
	# assumes the curated file has two header rows
	#  and the combination file has one header row
	$(RUN) combine_same_col_schemasheets \
		--input1 data/mixs_v6_checklists_env_packages_classes_curated.tsv \
		--input2 data/mixs_v6_checklists_env_packages_combination_classes_curated.tsv \
		--output $@ \

data/core_requirements.tsv: data/mixs_v6_MIxS.tsv
	# https://github.com/GenomicsStandardsConsortium/mixs/wiki/5.-MIxS-checklists
	$(RUN) melt_tsv \
		--input-file $< \
		--output-file $@ \
		--id-vars "Structured comment name" \
		--value-vars migs_ba \
		--value-vars migs_eu \
		--value-vars migs_org \
		--value-vars migs_pl \
		--value-vars migs_vi \
		--value-vars mimag \
		--value-vars mimarks_c \
		--value-vars mimarks_s \
		--value-vars mims \
		--value-vars misag \
		--value-vars miuvig \
		--output-col-name-1 slot \
		--output-col-name-2 class \
		--output-col-name-3 mixs_requirement_value

data/core_requirements_recommended_required.tsv: data/core_requirements.tsv data/mixs_requirement_codes.tsv
	poetry run python src/mixs_subset_examples_first/datamodel/merge_tsvs.py \
		--col-drop-col "not applicable" \
		--col-drop-col mixs_citation \
		--col-drop-col mixs_desc \
		--col-drop-col mixs_name \
		--col-drop-col optional \
		--row-drop-col "not applicable" \
		--file1 $(word 1,$^) \
		--file2 $(word 2,$^) \
		--on mixs_requirement_value \
		--output $@


data/codified_env_package_requirements.tsv: data/mixs_v6_environmental_packages.tsv data/mixs_requirement_codes.tsv
	$(RUN) codify_env_package_requirements \
		--ep-file $(word 1, $^) \
		--pascal-case-file data/mixs_v6_checklists_env_packages_classes_curated.tsv \
		--req-code-file $(word 2, $^) \
		--output-file $@

#creation of data/core_requirements_recommended_required_curated.tsv
#there should be two header rows, like this:
#slot	class	mixs_requirement_value	recommended	required
#> slot	class	ignore	recommended	required

# creating codified_env_package_requirements_curated.tsv
# insert second header with LinkML column specifications

data/database_slots.tsv: data/mixs_v6_asserted_and_combinations.tsv
	$(RUN) create_database_slots \
		--input-file $< \
		--output-file $@

# creating data/database_slots_curated.tsv
# add a second header row with LinkML column specifications

#src/mixs_subset_examples_first/schema/mixs_subset_examples_first_structpat.yaml: data/codified_env_package_requirements_curated.tsv \
#data/core_requirements_recommended_required_curated.tsv \
#data/database_slots_curated.tsv \
#data/enums.tsv \
#data/mixs_combined_all_modified_lossy_deduped.tsv \
#data/mixs_v6_asserted_and_combinations.tsv \
#data/prefixes.tsv \
#data/schema.tsv
#	$(RUN) sheets2linkml $^ > $@.tmp
#	yq eval-all -i 'select(fileIndex==0).settings = select(fileIndex==1).settings | select(fileIndex==0)' $@.tmp data/settings.yaml
#	poetry run add_interpolations \
#		--input-file $@.tmp \
#		--output-file $@
#	rm -rf src/mixs_subset_examples_first/schema/mixs_subset_examples_first.yaml
#	rm -rf $@.tmp


src/mixs_subset_examples_first/schema/mixs_subset_examples_first_structpat_only.yaml: data/schema.tsv \
data/prefixes.tsv data/classdefs.tsv data/mixs_combined_slotdefs.tsv data/database_slots_curated.tsv data/enums.tsv data/hand_stacked_for_slot_usages.csv
	$(RUN) sheets2linkml $^ > $@.tmp
	yq eval-all -i 'select(fileIndex==0).settings = select(fileIndex==1).settings | select(fileIndex==0)' $@.tmp data/settings.yaml
	poetry run add_interpolations \
		--input-file $@.tmp \
		--output-file $@
#	rm -rf src/mixs_subset_examples_first/schema/mixs_subset_examples_first.yaml
	rm -rf $@.tmp


src/mixs_subset_examples_first/schema/mixs_subset_examples_first.yaml: src/mixs_subset_examples_first/schema/mixs_subset_examples_first_structpat_only.yaml
	$(RUN) gen-linkml \
		--output $@ \
		--materialize-patterns \
		--no-materialize-attributes \
		--format yaml $<
	rm -rf $<

reports/mixs_subset_examples_first_materialized_patterns.yaml.linting.tsv: src/mixs_subset_examples_first/schema/mixs_subset_examples_first.yaml
	- $(RUN) linkml-lint \
 		--format tsv $< > $@

#  -f, --format [terminal|markdown|json|tsv]
#                                  Report format.  [default: terminal]
#  -o, --output FILENAME           Report file name.

#class StandardNamingRule(LinterRule):
#
#    id = "standard_naming"
#
#    def __init__(self, config: StandardNamingConfig) -> None:
#        self.config = config
#
#    def check(
#        self, schema_view: SchemaView, fix: bool = False
#    ) -> Iterable[LinterProblem]:
#        class_pattern = self.PATTERNS["uppercamel"]
#        slot_pattern = self.PATTERNS["snake"]
#        enum_pattern = self.PATTERNS["uppercamel"]
#        permissible_value_pattern = (
#            self.PATTERNS["uppersnake"]
#            if self.config.permissible_values_upper_case
#            else self.PATTERNS["snake"]
#        )

reports/Database-mimssoil_set-example.yaml.check-jsonschema.log: project/jsonschema/mixs_subset_examples_first.schema.json
	$(RUN) check-jsonschema --schemafile $< src/data/examples/valid/Database-migs_ba_soil_set-exhaustive.yaml
	$(RUN) check-jsonschema --schemafile $< src/data/examples/valid/Database-mims_plant_associated_set-exhaustive.yaml
	$(RUN) check-jsonschema --schemafile $< src/data/examples/valid/Database-mims_soil_set-exhaustive.yaml
	$(RUN) check-jsonschema --schemafile $< src/data/examples/valid/Database-mims_soil_set-minimalQ.yaml
	$(RUN) check-jsonschema --schemafile $< src/data/examples/valid/Database-mims_water_set-exhaustive.yaml
	! $(RUN) check-jsonschema --schemafile $< src/data/examples/invalid/Database-mims_soil_set-assembly_name-has-pipe.yaml
	! $(RUN) check-jsonschema --schemafile $< src/data/examples/invalid/Database-mims_soil_set-assembly_name-multivalued.yaml
	! $(RUN) check-jsonschema --schemafile $< src/data/examples/invalid/Database-mims_soil_set-bad-adapters-dna.yaml
	! $(RUN) check-jsonschema --schemafile $< src/data/examples/invalid/Database-mims_soil_set-bad-al_sat-float-unit.yaml
	! $(RUN) check-jsonschema --schemafile $< src/data/examples/invalid/Database-mims_soil_set-bad-al_sat_meth-pmid.yaml
	! $(RUN) check-jsonschema --schemafile $< src/data/examples/invalid/Database-mims_soil_set-bad-assembly-qual-enum.yaml
	! $(RUN) check-jsonschema --schemafile $< src/data/examples/invalid/Database-mims_soil_set-bad-assembly_software.yaml
	! $(RUN) check-jsonschema --schemafile $< src/data/examples/invalid/Database-mims_soil_set-bad-cur_land_use.yaml
	! $(RUN) check-jsonschema --schemafile $< src/data/examples/invalid/Database-mims_soil_set-bad-drainage_class.yaml
	! $(RUN) check-jsonschema --schemafile $< src/data/examples/invalid/Database-mims_soil_set-bad-env_broad_scale-term-id-only.yaml
	! $(RUN) check-jsonschema --schemafile $< src/data/examples/invalid/Database-mims_soil_set-bad-env_broad_scale-term-lab-only.yaml
	! $(RUN) check-jsonschema --schemafile $< src/data/examples/invalid/Database-mims_soil_set-bad-fao_class.yaml
	! $(RUN) check-jsonschema --schemafile $< src/data/examples/invalid/Database-mims_soil_set-bad-feat_pred.yaml
	! $(RUN) check-jsonschema --schemafile $< src/data/examples/invalid/Database-mims_soil_set-bad-geo_loc_name.yaml
	! $(RUN) check-jsonschema --schemafile $< src/data/examples/invalid/Database-mims_soil_set-bad-heavy_metals.yaml
	! $(RUN) check-jsonschema --schemafile $< src/data/examples/invalid/Database-mims_soil_set-missing-sample-name.yaml
	#
	#! $(RUN) check-jsonschema --schemafile $< src/data/examples/invalid/Database-mims_soil_set-bad-lat_lon.yaml
# \ src/data/examples/valid/Database-mims_soil_set-minimalQ.yaml
#> | tee $@

project/json/mixs_subset_examples_first.json: src/mixs_subset_examples_first/schema/mixs_subset_examples_first.yaml
	mkdir -p $(@D)
	$(RUN) gen-linkml \
		--format json  \
		--materialize-attributes \
		--materialize-patterns $< > $@

data/class_reverse_engineered.tsv:
	$(RUN) linkml2sheets \
		--output $@ \
		--schema src/mixs_subset_examples_first/schema/mixs_subset_examples_first.yaml data/class_template.tsv

examples/output/Database-mims_soil_set-exhaustive.json: src/mixs_subset_examples_first/schema/mixs_subset_examples_first.yaml \
src/data/examples/valid/Database-mims_soil_set-exhaustive.yaml
	$(RUN) linkml-convert \
		--output $@ \
		--schema $^

temp: proj_clean data/mixs_v6_environmental_packages.tsv data/mixs_v6_MIxS.tsv
# for the environmental package sheet, change all columns except slots and classes to annotations
# class names will probably need to be pascal-cased in real time or looked up in ???
# after the fact, we should flag classes or slots that don't appear in data/mixs_combined_all_modified_lossy_deduped.tsv
# some of the mixs_v6_environmental_packages.tsv slots should have been curated out, but some need to be reintroduced after re-curation
# would require extra schemasheets headers
