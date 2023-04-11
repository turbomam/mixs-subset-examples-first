## Add your own custom Makefile targets here

RUN = poetry run

.PHONY: check-jsonschema-example run-linkml-validation

check-jsonschema-example: project/jsonschema/mixs_subset_examples_first.schema.json \
	  src/data/examples/invalid/BiosampleCollection-undefined-slot.yaml
	# showing ignore failures here
	# this should be templated
	- $(RUN) check-jsonschema \
	  --schemafile $^

run-linkml-validation: src/mixs_subset_examples_first/schema/mixs_subset_examples_first.yaml \
src/data/examples/invalid/BiosampleCollection-undefined-slot.yaml
	# PersonCollection is assumed as the target-class because it has been defined as the tree_root in the schema
	- $(RUN) linkml-validate \
	  --schema $^


src/data/dh_vs_linkml_json/BiosampleCollection_linkml_raw.yaml: src/data/dh_vs_linkml_json/Biosample_dh.json
	$(RUN) dh-json2linkml \
		--input-file $< \
		--output-file $@ \
		--output-format yaml \
		--key entries


src/data/dh_vs_linkml_json/BiosampleCollection_linkml_normalized.yaml: src/data/dh_vs_linkml_json/BiosampleCollection_linkml_raw.yaml
	$(RUN) linkml-normalize \
		--schema src/mixs_subset_examples_first/schema/mixs_subset_examples_first.yaml \
		--output $@ \
		--no-expand-all $<

src/data/dh_vs_linkml_json/entries.json: src/data/dh_vs_linkml_json/BiosampleCollection_linkml_normalized.yaml
	$(RUN) linkml-json2dh \
		--input-file $< \
		--input-format yaml \
		--output-dir $(dir $@)

project/reports/slot_usage_esp_validation.tsv:
	linkml2sheets \
		--schema src/mixs_subset_examples_first/schema/mixs_subset_examples_first.yaml \
		--output $@ \
		src/local_schemasheets/templates/slot_usage_esp_validation.tsv

###   ###   ###

# Define a list of sheet names to extract.
SHEET_NAMES := MIxS environmental_packages

.PHONY: comprehensive_cleanup extract_all_sheets management_all modification_lifecycle post_col_diff_report pre_col_diff_report pre_modifications report_id_item_multi_pairings report_id_scn_multi_pairings report_sc_item_multi_pairings tsvs_cleanup

package_selection: comprehensive_cleanup assets/worts_offender_details.tsv

assets/worts_offender_details.tsv: assets/mixs_combined.tsv
	$(RUN) worst_offenders \
		--input-tsv $< \
		--averages-report-tsv assets/worst_offender_averages.tsv \
		--details-report-tsv $@

pre_modifications: comprehensive_cleanup extract_all_sheets assets/pre_col_diff_report.out management_all assets/post_col_diff_report.out \
assets/mixs_combined.tsv \
assets/report_pre_id_scn_multi_pairings.out assets/report_pre_sc_item_multi_pairings.out assets/report_pre_id_item_multi_pairings.out

post_modifications: assets/report_post_id_scn_multi_pairings.out assets/report_post_id_scn_multi_pairings.out  assets/report_post_sc_item_multi_pairings.out \
assets/mixs_uniform_terms.tsv assets/mixs_combined_diff.html

comprehensive_cleanup: tsvs_cleanup management_cleanup diff_cleanup
	rm -rf \
assets/drop_then_remove_dupes.out \
assets/mixs_combined_conservative.tsv \
assets/mixs_combined_diff_conservative.html \
assets/mixs_combined_original.tsv \
assets/mixs_conflicting_terms.tsv \
assets/mixs_uniform_terms.tsv \
assets/post_col_diff_report.out \
assets/pre_col_diff_report.out \
assets/report_id_item_multi_pairings.out \
assets/report_id_scn_multi_pairings.out \
assets/report_post_id_item_multi_pairings.out \
assets/report_post_id_scn_multi_pairings.out \
assets/report_post_sc_item_multi_pairings.out \
assets/report_pre_id_item_multi_pairings.out \
assets/report_pre_id_scn_multi_pairings.out \
assets/report_pre_sc_item_multi_pairings.out \
assets/report_post_id_item_scn_multi_pairings.out


diff_cleanup:
	rm -rf assets/mixs_combined_no_752.tsv assets/mixs_combined_modified_no_752.tsv assets/mixs_combined_diff.html

management_cleanup:
	rm -rf assets/mixs_v6_MIxS_managed_keys.tsv assets/mixs_v6_environmental_packages_managed_keys.tsv assets/mixs_v6_environmental_packages_managed_keys_filtered.tsv

tsvs_cleanup:
	rm -rf \
assets/mixs_combined.tsv \
assets/mixs_v6.xlsx \
assets/mixs_v6_MIxS.tsv \
assets/mixs_v6_MIxS_managed_keys.tsv \
assets/mixs_v6_environmental_packages.tsv \
assets/mixs_v6_environmental_packages_managed_keys.tsv \
assets/mixs_v6_environmental_packages_managed_keys_filtered.tsv \
assets/*tsv

## Chris Mungall and Chris Hunter prefer not to the MIxS Google Sheets in
##   https://docs.google.com/spreadsheets/d/1QDeeUcDqXes69Y2RjU2aWgOpCVWo5OVsBX9MKmMqi_o
##   - They have already been converted into Mungall's https://github.com/GenomicsStandardsConsortium/mixs/tree/main/model/schema by mixs_converter.py
##   - They could have theoretically been changed since the MIxS 6.1 release was made

assets/mixs_v6.xlsx:
	curl -L "https://github.com/GenomicsStandardsConsortium/mixs/raw/mixs6.1.0/mixs/excel/mixs_v6.xlsx" > $@

assets/pre_col_diff_report.out: assets/mixs_v6_MIxS.tsv assets/mixs_v6_environmental_packages.tsv
	$(RUN) compare_headers \
		--file1 $(word 1, $^) \
		--file2  $(word 2, $^)  | tee $@

# Define a pattern rule to generate TSV files for all sheets in the XLSX file.
assets/mixs_v6_%.tsv: assets/mixs_v6.xlsx
	$(RUN) xlsx_tab_to_tsv \
		--log_level INFO \
		--sheet $* \
		--tsv_output $@ \
		--xlsx_input $<

extract_all_sheets: assets/mixs_v6.xlsx $(patsubst %,assets/mixs_v6_%.tsv,$(SHEET_NAMES))

assets/mixs_v6_MIxS_managed_keys.tsv: assets/mixs_v6_MIxS.tsv
	$(RUN) tsv_key_management \
		--input-tsv $< \
		--output-tsv $@ \
		--key-to-remove migs_ba \
		--key-to-remove migs_eu \
		--key-to-remove migs_org \
		--key-to-remove migs_pl \
		--key-to-remove migs_vi \
		--key-to-remove mimag \
		--key-to-remove mimarks_c \
		--key-to-remove mimarks_s \
		--key-to-remove mims \
		--key-to-remove misag \
		--key-to-remove miuvig \
		--rename-column "Item (rdfs:label)" Item \
		--rename-column Occurence Occurrence

assets/mixs_v6_environmental_packages_managed_keys.tsv: assets/mixs_v6_environmental_packages.tsv
	$(RUN) tsv_key_management \
		--input-tsv $< \
		--output-tsv $@ \
		--key-to-remove Requirement \
		--rename-column "Package item" Item

management_all: management_cleanup assets/mixs_v6_MIxS_managed_keys.tsv assets/mixs_v6_environmental_packages_managed_keys_filtered.tsv


assets/mixs_v6_environmental_packages_managed_keys_filtered.tsv: assets/mixs_v6_environmental_packages_managed_keys.tsv
	# add agriculture if you want to see conflicts
	# --accepted-value agriculture \
	$(RUN) filter_column \
		--input-tsv $< \
		--filter-column 'Environmental package' \
		--accepted-value soil \
		--accepted-value water \
		--accepted-value 'food-farm environment' \
		--accept-empties \
		--output-tsv $@

assets/post_col_diff_report.out: assets/mixs_v6_MIxS_managed_keys.tsv assets/mixs_v6_environmental_packages_managed_keys_filtered.tsv
	$(RUN) compare_headers \
		--file1 $(word 1, $^) \
		--file2  $(word 2, $^) | tee $@

assets/mixs_combined.tsv: assets/mixs_v6_MIxS_managed_keys.tsv assets/mixs_v6_environmental_packages_managed_keys_filtered.tsv
	$(RUN) combine_any_tsvs \
	  --input-tsv1 $(word 1, $^) \
	  --input-tsv2 $(word 2, $^) \
	  --column-order "MIXS ID","Structured comment name","Item","Environmental package","Section","Expected value","Value syntax","Occurrence","Preferred unit","Example","Definition" \
	  --output-tsv $@

assets/report_pre_id_scn_multi_pairings.out: assets/mixs_combined.tsv
	$(RUN) find_multi_pairings \
		--input_tsv $< \
		--column_a "MIXS ID" \
		--column_b "Structured comment name" | tee $@

assets/report_pre_sc_item_multi_pairings.out: assets/mixs_combined.tsv
	$(RUN) find_multi_pairings \
		--input_tsv $< \
		--column_a "Structured comment name" \
		--column_b "Item" | tee $@

assets/report_pre_id_item_multi_pairings.out: assets/mixs_combined.tsv
	$(RUN) find_multi_pairings \
		--input_tsv $< \
		--column_a "MIXS ID" \
		--column_b "Item" | tee $@


#assets/report_post_id_scn_multi_pairings.out: assets/mixs_combined_modified.tsv
#	$(RUN) find_multi_pairings \
#		--input_tsv $< \
#		--column_a "MIXS ID" \
#		--column_b "Structured comment name" | tee $@
#
#assets/report_post_sc_item_multi_pairings.out: assets/mixs_combined_modified.tsv
#	$(RUN) find_multi_pairings \
#		--input_tsv $< \
#		--column_a "Structured comment name" \
#		--column_b "Item" | tee $@
#
#assets/report_post_id_item_multi_pairings.out: assets/mixs_combined_modified.tsv
#	$(RUN) find_multi_pairings \
#		--input_tsv $< \
#		--column_a "MIXS ID" \
#		--column_b "Item" | tee $@
#
#
### WHICH COLUMNS TO DROP?
## denoters
#  #MIXS ID
#  #Structured comment name
#  #Item
#
## context
#  #Environmental package
#  #Section
#
#  #Expected value
#  #Value syntax
#  #Occurrence
#  #Preferred unit
#  #Definition
#
## package specific
#  #Example
#
#assets/mixs_uniform_terms.tsv: assets/mixs_combined_modified.tsv
#	$(RUN) drop_then_remove_dupes \
#		--input-tsv $< \
#		--uniform-terms-out $@ \
#		--conflicting-terms-out $(subst uniform,conflicting, $@) \
#		--drop-field "Environmental package" \
#		--drop-field "Section" \
#		--drop-field "Example" | tee assets/drop_then_remove_dupes.out
#
### comparing some rows crashes csvdiff
### todo: don't foget to specify which csvdiff we're using
##assets/mixs_combined_conservative.tsv: assets/mixs_combined.tsv
##	grep -v "MIXS:0000752" $< | \
##	grep -v "MIXS:0000755" | \
##	grep -v "MIXS:0001230" > $@
##
##assets/mixs_combined_modified_conservative.tsv: assets/mixs_combined_modified.tsv
##	grep -v "MIXS:0000752" $< | \
##	grep -v "MIXS:0000755" | \
##	grep -v "MIXS:0001230" > $@
#
## this may not work on Macs
## ie may only work on Linux esp Ubuntu
#assets/mixs_combined_diff.html: assets/mixs_combined.tsv assets/mixs_combined_modified.tsv
#	script -q -c "csvdiff --separator '\t'  --primary-key 0,3,4 --format word-diff  $^" | aha > $@
