# CAR Scraper

## Requirements

* Python 3
* pdfinfo (available as part of [Xpdf](http://www.foolabs.com/xpdf/download.html) - mac users can also use the [Poppler](https://poppler.freedesktop.org/) fork via homebrew: `brew install poppler`)

Make a virtualenv and install Python requirements:

```
mkvirtualenv car-scraper
pip install -U -r requirements.txt
```

Build tabula-java from source:

```
make tabula-java
```

Decrypt the login credentials:

```
blackbox_cat configs/secrets.py.gpg > scripts/secrets.py
```

Set the desired month and year at the top of the `Makefile`:

```bash
# follow this format:
year = 2016
month = 02
```
