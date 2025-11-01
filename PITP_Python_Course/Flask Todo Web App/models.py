# Import SQLAlchemy for database ORM
from flask_sqlalchemy import SQLAlchemy
# UserMixin provides default implementations for Flask-Login user methods
from flask_login import UserMixin
from datetime import datetime  # For timestamps

# Initialize SQLAlchemy (we will link it to app in app.py)
db = SQLAlchemy()

# -------------------
# User Model
# -------------------
class User(db.Model, UserMixin):
    id = db.Column(db.Integer, primary_key=True)  # Unique ID for each user
    username = db.Column(db.String(150), unique=True, nullable=False)  # Username (must be unique)
    email = db.Column(db.String(150), unique=True, nullable=False)  # Email (must be unique)
    password = db.Column(db.String(150), nullable=False)  # Hashed password
    # One-to-many relationship: A user can have multiple tasks
    tasks = db.relationship('Task', backref='owner', lazy=True)

# -------------------
# Task Model
# -------------------
class Task(db.Model):
    id = db.Column(db.Integer, primary_key=True)  # Unique ID for each task
    title = db.Column(db.String(200), nullable=False)  # Task title (required)
    description = db.Column(db.Text, nullable=True)  # Optional task description
    date_created = db.Column(db.DateTime, default=datetime.utcnow)  # Timestamp when task is created
    # Foreign key linking task to a specific user
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
