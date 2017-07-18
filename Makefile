include pdf_bounds.mk config.mk

.PHONY: all clean

all: final/chicago_yearly_price_data_$(month)_$(year).csv \
	final/suburb_yearly_price_data_$(month)_$(year).csv \
	final/chicago_monthly_price_data_$(month)_$(year).csv \
	final/suburb_monthly_price_data_$(month)_$(year).csv \
	final/county_yearly_price_data_$(month)_$(year).csv \
	final/county_monthly_price_data_$(month)_$(year).csv

clean:
	rm -Rf raw/
	rm cleaned_csvs raw_csvs pdfs conversion_errors.csv

tabula-java :
	mkdir -p tabula-java
	(cd tabula-java && wget $(tabula-download))

pdfs:
	mkdir -p raw/pdfs
	python scripts/retrieve_pdfs.py $(month) $(year)
	touch $@

raw_csvs: pdfs
	mkdir -p raw/csvs/chicago raw/csvs/suburbs raw/csvs/county-summaries
	for pdf in raw/pdfs/*.pdf; do \
		export fname=$$(basename "$$pdf" .pdf); \
		echo $$fname; \
		if [[ $(pdf-pages) == 4 ]]; then \
			case "$${fname}" in \
				*"DuPage_County"*) \
					export p2_cols=$(p24-dupage-cols); \
					export p3_cols=$(p3-dupage-cols); \
					export p4_cols=$(p24-dupage-cols); \
					;; \
				*"Lake_County"*) \
					export p2_cols=$(p24-lake-cols); \
					export p3_cols=$(p3-lake-cols); \
					export p4_cols=$(p24-lake-cols); \
					;; \
				*"North_Cook"*) \
					export p2_cols=$(p24-north-cols); \
					export p3_cols=$(p3-north-cols); \
					export p4_cols=$(p24-north-cols); \
					;; \
				*"South_Cook"*) \
					export p2_cols=$(p24-south-cols); \
					export p3_cols=$(p3-south-cols); \
					export p4_cols=$(p24-south-cols); \
					;; \
				*"West_Cook"*) \
					export p2_cols=$(p24-west-cols); \
					export p3_cols=$(p3-west-cols); \
					export p4_cols=$(p24-west-cols); \
					;; \
				*"Will_County"*) \
					export p2_cols=$(p24-will-cols); \
					export p3_cols=$(p3-will-cols); \
					export p4_cols=$(p24-will-cols); \
					;; \
			esac; \
			$(tabula) -p 1 -a $(p1-county-bounds) -c $(p1-cols) "$$pdf" > "raw/csvs/county-summaries/$${fname}.csv" && \
			$(tabula) -p 2 -a $(p234-county-bounds) -c $$p2_cols "$$pdf" > "raw/csvs/suburbs/$${fname}_2.csv" && \
			$(tabula) -p 3 -a $(p234-county-bounds) -c $$p3_cols "$$pdf" > "raw/csvs/suburbs/$${fname}_3.csv" && \
			$(tabula) -p 4 -a $(p234-county-bounds) -c $$p4_cols "$$pdf" > "raw/csvs/suburbs/$${fname}_4.csv"; \
		else \
			$(tabula) -p 1 -a $(p1-chicago-bounds) -c $(p1-cols) "$$pdf" > "raw/csvs/chicago/$${fname}.csv"; \
		fi \
	done
	touch $@

cleaned_csvs: raw_csvs
	mkdir -p raw/csvs/chicago/clean raw/csvs/suburbs/clean raw/csvs/county-summaries/clean
	if [ -f conversion_errors.csv ]; then \
		rm conversion_errors.csv; \
	fi
	touch conversion_errors.csv
	echo "Cleaning Chicago reports..."
	for csv in raw/csvs/chicago/*.csv; \
	do \
		export fname=$$(basename "$$csv" .csv); \
		cat "$$csv" | python scripts/clean_price_data.py "$$fname" $(year) "yearly" > "raw/csvs/chicago/clean/$${fname}_yearly.csv"; \
		cat "$$csv" | python scripts/clean_price_data.py "$$fname" $(year) "monthly" > "raw/csvs/chicago/clean/$${fname}_monthly.csv"; \
		cat "raw/csvs/chicago/clean/$${fname}_yearly.csv" | \
			python scripts/test_price_data_conversion.py "raw/csvs/chicago/clean/$${fname}_yearly.csv" \
			>> "conversion_errors.csv" 2>&1; \
		cat "raw/csvs/chicago/clean/$${fname}_monthly.csv" | \
			python scripts/test_price_data_conversion.py "raw/csvs/chicago/clean/$${fname}_monthly.csv" \
			>> "conversion_errors.csv" 2>&1; \
	done
	echo "Cleaning county summary reports..."
	for csv in raw/csvs/county-summaries/*.csv; \
	do \
		export fname=$$(basename "$$csv" .csv); \
		cat "$$csv" | python scripts/clean_price_data.py "$$fname" $(year) "yearly" > "raw/csvs/county-summaries/clean/$${fname}_yearly.csv"; \
		cat "$$csv" | python scripts/clean_price_data.py "$$fname" $(year) "monthly" > "raw/csvs/county-summaries/clean/$${fname}_monthly.csv"; \
		cat "raw/csvs/county-summaries/clean/$${fname}_yearly.csv" | \
			python scripts/test_price_data_conversion.py "raw/csvs/county-summaries/clean/$${fname}_yearly.csv" \
			>> "conversion_errors.csv" 2>&1; \
		cat "raw/csvs/county-summaries/clean/$${fname}_monthly.csv" | \
			python scripts/test_price_data_conversion.py "raw/csvs/county-summaries/clean/$${fname}_monthly.csv" \
			>> "conversion_errors.csv" 2>&1; \
	done
	echo "Cleaning suburb reports..."
	for csv in raw/csvs/suburbs/*.csv; do \
		export fname=$$(eval basename $$csv .csv); \
		cat "$$csv" | python scripts/clean_price_data.py "$$fname" $(year) "yearly" > "raw/csvs/suburbs/clean/$${fname}_yearly.csv"; \
		cat "$$csv" | python scripts/clean_price_data.py "$$fname" $(year) "monthly" > "raw/csvs/suburbs/clean/$${fname}_monthly.csv"; \
		cat "raw/csvs/suburbs/clean/$${fname}_yearly.csv" | \
			python scripts/test_price_data_conversion.py "raw/csvs/suburbs/clean/$${fname}_yearly.csv" \
			>> "conversion_errors.csv" 2>&1; \
		cat "raw/csvs/suburbs/clean/$${fname}_monthly.csv" | \
			python scripts/test_price_data_conversion.py "raw/csvs/suburbs/clean/$${fname}_monthly.csv" \
			>> "conversion_errors.csv" 2>&1; \
	done
	cat conversion_errors.csv
	touch $@

final/chicago_yearly_price_data_%.csv: cleaned_csvs
	mkdir -p final
	csvstack raw/csvs/chicago/clean/*_yearly.csv > $@

final/chicago_monthly_price_data_%.csv: cleaned_csvs
	mkdir -p final
	csvstack raw/csvs/chicago/clean/*_monthly.csv > $@

final/county_yearly_price_data_%.csv: cleaned_csvs
	mkdir -p final
	csvstack raw/csvs/county-summaries/clean/*_yearly.csv > $@

final/county_monthly_price_data_%.csv: cleaned_csvs
	mkdir -p final
	csvstack raw/csvs/county-summaries/clean/*_monthly.csv > $@

final/suburb_yearly_price_data_%.csv: cleaned_csvs
	mkdir -p final
	for csv in raw/csvs/suburbs/clean/*_2_yearly.csv; do \
		export fname=$$(basename "$$csv" _2_yearly.csv); \
		export fnames=$$(echo raw/csvs/suburbs/clean/$${fname}_*_yearly.csv); \
		csvjoin -I -c "community" $$fnames > "raw/csvs/suburbs/clean/$${fname}_yearly_final.csv"; \
	done
	csvstack raw/csvs/suburbs/clean/*_yearly_final.csv | sort -r -u | csvsort -I -c 1 > $@
	rm raw/csvs/suburbs/clean/*_yearly_final.csv

final/suburb_monthly_price_data_%.csv: cleaned_csvs
	mkdir -p final
	for csv in raw/csvs/suburbs/clean/*_2_monthly.csv; do \
		export fname=$$(basename "$$csv" _2_monthly.csv); \
		export fnames=$$(echo raw/csvs/suburbs/clean/$${fname}_*_monthly.csv); \
		csvjoin -I -c "community" $$fnames > "raw/csvs/suburbs/clean/$${fname}_monthly_final.csv"; \
	done
	csvstack raw/csvs/suburbs/clean/*_monthly_final.csv | sort -r -u | csvsort -I -c 1 > $@
	rm raw/csvs/suburbs/clean/*_monthly_final.csv
