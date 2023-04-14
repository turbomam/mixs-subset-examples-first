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

.PHONY: clean report_contradiction_scores extract_all_sheets column_alignment_all modification_lifecycle post_column_alignment_diff_report pre_column_alignment_diff_report pre_modifications report_id_item_contradictions report_id_scn_contradictions report_sc_item_contradictions tsvs_cleanup

clean: target_cleanup downloads_cleanup reports_cleanup

report_contradiction_scores: clean reports/contradiction_score_details.tsv

reports/contradiction_score_details.tsv: data/mixs_combined_all.tsv
	$(RUN) contradiction_score_reports \
		--summary-report-tsv $(subst details,summary,$@) \
		--details-report-tsv $@ \
		--excluded-cols "Environmental package" \
		--excluded-cols "Example" \
		--excluded-cols "Preferred unit" \
		--excluded-cols "Section" \
		--input-tsv $<

pre_modifications_reports: clean extract_all_sheets \
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
	mkdir -p downloads
	touch downloads/.gitkeep
	rm -rf reports/report_pre_id_scn_contradictions.yaml



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


do_post_reports: clean_reports \
reports/report_post_id_scn_contradictions.yaml \
reports/report_post_id_item_contradictions.yaml \
reports/report_post_id_occurrence_contradictions.yaml \
reports/report_post_id_prefunit_contradictions.yaml \
reports/report_post_id_example_contradictions.yaml \
reports/report_post_id_description_contradictions.yaml

clean_reports:
	rm -rf reports/report_post_*_contradictions.yaml

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

