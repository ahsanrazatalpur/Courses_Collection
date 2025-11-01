from flask import Flask, render_template, redirect, url_for, flash, request
from flask_sqlalchemy import SQLAlchemy  # For database ORM
from flask_login import LoginManager, login_user, login_required, logout_user, current_user
from werkzeug.security import generate_password_hash, check_password_hash  # For password hashing

# Import database models and forms
from models import db, User, Task
from forms import RegistrationForm, LoginForm, TaskForm

# -------------------
# 1. Initialize Flask app
# -------------------
app = Flask(__name__)  # Create a Flask web application instance
app.config['SECRET_KEY'] = 'your_secret_key'  # Secret key for session and CSRF protection
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///todo.db'  # SQLite database path

# Initialize SQLAlchemy with the app
db.init_app(app)

# -------------------
# 2. Initialize Flask-Login
# -------------------
login_manager = LoginManager()  # Create login manager instance
login_manager.login_view = 'login'  # Redirect unauthorized users to login page
login_manager.init_app(app)  # Link login manager with Flask app

# Tell Flask-Login how to load a user from the database
@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))  # Get user by primary key (id)

# -------------------
# 3. Create database tables (Flask 3.x compatible)
# -------------------
# Flask 3.x removed before_first_request, so we use app context on startup
with app.app_context():
    db.create_all()  # Creates all tables if they don't exist

# -------------------
# 4. Routes / Views
# -------------------

# Homepage/dashboard showing user's tasks
@app.route('/')
@login_required
def index():
    tasks = Task.query.filter_by(user_id=current_user.id).all()
    return render_template('index.html', tasks=tasks)

# Registration page
@app.route('/register', methods=['GET', 'POST'])
def register():
    form = RegistrationForm()
    if form.validate_on_submit():
        hashed_password = generate_password_hash(form.password.data)
        user = User(username=form.username.data, email=form.email.data, password=hashed_password)
        db.session.add(user)
        db.session.commit()
        flash('Account created! You can now login.', 'success')
        return redirect(url_for('login'))
    return render_template('register.html', form=form)

# Login page
@app.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        user = User.query.filter_by(email=form.email.data).first()
        if user and check_password_hash(user.password, form.password.data):
            login_user(user)
            return redirect(url_for('index'))
        else:
            flash('Login failed. Check email and password', 'danger')
    return render_template('login.html', form=form)

# Logout route
@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))

# Add new task
@app.route('/add', methods=['GET', 'POST'])
@login_required
def add_task():
    form = TaskForm()
    if form.validate_on_submit():
        task = Task(title=form.title.data, description=form.description.data, owner=current_user)
        db.session.add(task)
        db.session.commit()
        flash('Task added!', 'success')
        return redirect(url_for('index'))
    return render_template('task_form.html', form=form, title='Add Task')

# Edit existing task
@app.route('/edit/<int:task_id>', methods=['GET', 'POST'])
@login_required
def edit_task(task_id):
    task = Task.query.get_or_404(task_id)
    if task.owner != current_user:
        flash("You can't edit this task!", 'danger')
        return redirect(url_for('index'))
    form = TaskForm(obj=task)
    if form.validate_on_submit():
        task.title = form.title.data
        task.description = form.description.data
        db.session.commit()
        flash('Task updated!', 'success')
        return redirect(url_for('index'))
    return render_template('task_form.html', form=form, title='Edit Task')

# Delete task
@app.route('/delete/<int:task_id>')
@login_required
def delete_task(task_id):
    task = Task.query.get_or_404(task_id)
    if task.owner != current_user:
        flash("You can't delete this task!", 'danger')
        return redirect(url_for('index'))
    db.session.delete(task)
    db.session.commit()
    flash('Task deleted!', 'success')
    return redirect(url_for('index'))

# Run the app
if __name__ == '__main__':
    app.run(debug=True)
