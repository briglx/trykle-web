# trykle-web
Water management controler Web app

# Dev Setup
Build your front-end code into production ready, minified assets
Upload assets to storage
Configure backend to use assets in storage

```bash
cd /path/to/webapp
 
#Tell the terminal what application to run
export FLASK_APP=main.py

#Tell the terminal what application to run for windows
set FLASK_APP=main.py

#Run the application
flask run
```

Deploy to Azure web app
```bash
az webapp up --name trykle
```