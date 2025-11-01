# Import FlaskForm for creating forms
from flask_wtf import FlaskForm
# Form fields
from wtforms import StringField, PasswordField, SubmitField, TextAreaField
# Validators to enforce input rules
from wtforms.validators import DataRequired, Length, Email, EqualTo

# -------------------
# Registration Form
# -------------------
class RegistrationForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired(), Length(min=2, max=20)])
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[DataRequired()])
    # Confirm password must match password field
    confirm_password = PasswordField('Confirm Password', validators=[DataRequired(), EqualTo('password')])
    submit = SubmitField('Sign Up')  # Submit button

# -------------------
# Login Form
# -------------------
class LoginForm(FlaskForm):
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[DataRequired()])
    submit = SubmitField('Login')

# -------------------
# Task Form (Add/Edit Task)
# -------------------
class TaskForm(FlaskForm):
    title = StringField('Title', validators=[DataRequired()])  # Task title (required)
    description = TextAreaField('Description')  # Optional description
    submit = SubmitField('Save Task')  # Submit button
