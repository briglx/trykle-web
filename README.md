# trykle-web
Water management controller Web app

# Dev Setup

Install requirements and configure local environment variables

```bash
pip install -r requirements_dev.txt
cp .env-example .env
```

Run application

```bash
cd /path/to/webapp

#Tell the terminal what application to run
export FLASK_APP=app.py

#Tell the terminal what application to run for windows
set FLASK_APP=app.py

#Run the application
flask run
```

Deploy to Azure web app
```bash
az webapp up --name trykle
```

## Database Setup

Create a SQL Database

```
servername: trykle
admin: trykle
passsword: ****
location: westus2
```

Execute the `createdb.sql` to create the tables

Install Driver on local machine
https://docs.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server?redirectedfrom=MSDN&view=sql-server-ver15


Create records in db using Flask
```bash
from app import db
from app import app
app.app_context().push()
db.create_all()
from trykleapp import Zone
zone = Zone(zone_name="Test")
db.session.add(zone)
db.session.commit()
```

# Development

## Style Guidelines
This project enforces quite strict PEP8 and PEP257 (Docstring Conventions) compliance on all code submitted.
We use Black for uncompromised code formatting.

Summary of the most relevant points:

- Comments should be full sentences and end with a period.
- Imports should be ordered.
- Constants and the content of lists and dictionaries should be in alphabetical order.
- It is advisable to adjust IDE or editor settings to match those requirements.

## Ordering of imports
Instead of ordering the imports manually, use isort.

```bash
pip3 install isort
isort -rc .
```

## Use new style string formatting
Prefer f-strings over % or str.format.

```bash
#New
f"{some_value} {some_other_value}"
# Old, wrong
"{} {}".format("New", "style")
"%s %s" % ("Old", "style")
```
One exception is for logging which uses the percentage formatting. This is to avoid formatting the log message when it is suppressed.

```bash
_LOGGER.info("Can't connect to the webservice %s at %s", string1, string2)
```

## Testing
As it states in the Style Guidelines section all code is checked to verify the following:

- All code passes the checks from the linting tools

```bash
isort -rc .
codespell  --skip="./.*,*.pyc,*.png,./static/js/bootstrap*,./static/css/bootstrap*,*.vsdx"
black .
flake8 .
pylint .
pydocstyle .
```

# References
- Using SqlAlchemy https://medium.com/@anushkamehra16/connecting-to-sql-database-using-sqlalchemy-in-python-2be2cf883f85
