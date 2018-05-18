# CAR Scraper

Grab Chicagoland real estate reports from the CAR website and convert them all to spreadsheets.

### Requirements

Make sure you have OS-level requirements installed:

* Python 3.3+ (standard DataMade tool)
* Java (or any JRE)
* pdfinfo (built-in on Ubuntu, available for other Linux distros as part of [Xpdf](http://www.foolabs.com/xpdf/download.html) - mac users can also use the [Poppler](https://poppler.freedesktop.org/) fork via homebrew: `brew install poppler`)

Then, make a virtualenv and install Python requirements:

```
mkvirtualenv car-scraper
pip install -U -r requirements.txt
```

Finally, build tabula-java 0.9.1 from source:

```
make tabula-java
```

### Running the scraper

You'll need to decrypt the CAR login credentials before you can scrape the PDFs.
If you're on the keyring for this repo, you can decrypt the secrets file:

```
blackbox_cat configs/secrets.py.gpg > scripts/secrets.py
```

Otherwise, copy over the example secrets file:

```
cp configs/secrets.example.py > scripts/secrets.py
```

Then, adjust the variables to reflect your CAR username and password:

```
CAR_USER = '<your_username>'
CAR_PASS = '<your_password>'
```

Set the desired month and year for the reports in `config.mk`:

```bash
# follow this format:
year = 2016
month = 02
```

Use the DataMade Make standard operating procedure to get your files. `make all` produces the final output for the year/month you selected, and `make clean` removes all generated files from your repo.

### Output

Output files land in the `final/` directory. Files with `monthly` in the name catalogue month-over-month statistics, while files with `yearly` in the name catalogue year-to-date totals. 

If you're interested in year-end statistics, just run the scraper for December of a given year (`$(month) = 12`) and grab the `yearly` files. **These are the files we use in Where to Buy.**

### Errors

In the process of cleaning the CSVs, the scraper will double-check to make sure that table values look plausible. It will print these errors to the console while making the target `cleaned_csvs`, but you can also examine the output file `conversion_errors.csv` if you want to inspect further. Error messages look something like this:

```
Percentage error in raw/csvs/suburbs/clean/DuPage_County_4.csv
Community: Carol Stream
Column: months_supply_change
Row value: -35.8
Calculated delta: -34.5
(Note: calculated deltas should be within +-1 of the row value.)
```

CAR often slightly miscalculates changes in values between years, as you can see above. This is the most frequent error I've encountered, and you can safely ignore it as long as the delta is within a reasonable range.

### Team

* Jean Cochrane - code
* Forest Gregg - mentorship


