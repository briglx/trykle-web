"""Main web app file."""
import os

from dotenv import load_dotenv
from flask import Flask, render_template

# from flask_sqlalchemy import SQLAlchemy
from werkzeug.middleware.proxy_fix import ProxyFix

# from sqlalchemy import create_engine

# from .forms import EditZoneForm

basedir = os.path.abspath(os.path.dirname(__file__))
dotenv_path = os.path.join(os.path.dirname(__file__), ".env")
if os.path.exists(dotenv_path):
    load_dotenv(dotenv_path)

SECRET_KEY = os.environ.get("SECRET_KEY") or "hard to guess string"
# SQLALCHEMY_DATABASE_URI = os.environ.get("DATABASE_URL") or "sqlite:///" + os.path.join(
#     basedir, "data.sqlite"
# )
# SQLALCHEMY_DATABASE_URI = "sqlite:///" + os.path.join(
#     basedir, "data.sqlite"
# )

# db = SQLAlchemy()

app = Flask(__name__)
app.config["SECRET_KEY"] = SECRET_KEY
# app.config["SQLALCHEMY_DATABASE_URI"] = SQLALCHEMY_DATABASE_URI
# db.init_app(app)

# Fix Azure webapp proxy
app.wsgi_app = ProxyFix(app.wsgi_app)


# # pylint: disable=R0903
# class Zone(db.Model):
#     """Zone contains all the information about a zone in the yard."""

#     zone_id = db.Column(db.Integer, primary_key=True)
#     zone_name = db.Column(db.String(50), nullable=True)
#     image_url = db.Column(db.String(255), nullable=True)
#     schedule_id = db.Column(db.Integer, nullable=True)

#     def __repr__(self):
#         """Return a string representation of the zone."""
#         return f"Zone('{self.zone_name}', '{self.image_url}')"


zones = [
    {"id": 1, "zone_name": "Front Lawn", "image_url": "", "schedule_id": None},
    {"id": 2, "zone_name": "Front Plants", "image_url": "", "schedule_id": None},
    {"id": 3, "zone_name": "Front Yard Plants", "image_url": "", "schedule_id": None},
    {"id": 4, "zone_name": "Front Yard Plants", "image_url": "", "schedule_id": None},
    {"id": 5, "zone_name": "Front Yard Grass", "image_url": "", "schedule_id": None},
    {"id": 6, "zone_name": "Front Yard Plants", "image_url": "", "schedule_id": None},
    {"id": 7, "zone_name": "Front Yard Plants", "image_url": "", "schedule_id": None},
    {"id": 8, "zone_name": "Front Yard Plants", "image_url": "", "schedule_id": None},
]


@app.route("/")
@app.route("/home")
def home():
    """Render the index page."""
    # engine = create_engine(SQLALCHEMY_DATABASE_URI)
    # result = engine.execute("select * from zone")
    # for row in result:
    #     print(row)
    # result.close()

    # data = Zone.query.all()
    # for row in data:
    #     print(row)

    return render_template("pages/home.html", zones=zones[:8])


@app.route("/zone/")
def all_zones():
    """Render the zone page."""
    return render_template("pages/zone.html", zones=zones[:8])


@app.route("/zone/<zone_id>", methods=["GET", "POST"])
def zone_detail(zone_id):
    """Render the zone detail page."""
    # form = EditZoneForm()
    # if form.validate_on_submit():
    #     f = form.photo.data
    #     filename = secure_filename(f.filename)

    cur_zone = zones[int(zone_id)]
    return render_template("pages/zone_detail.html", zone=cur_zone)


if __name__ == "__main__":
    print("Running from app.py")
    app.run()
