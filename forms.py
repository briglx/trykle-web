from flask_wtf import FlaskForm
from flask_wtf.file import FileField, FileRequired
from wtforms import StringField, SubmitField
from wtforms.validators import Length


class EditZoneForm(FlaskForm):
    name = StringField("Zone name", validators=[Length(0, 64)])
    photo = FileField(validators=[FileRequired()])
    submit = SubmitField("Submit")
