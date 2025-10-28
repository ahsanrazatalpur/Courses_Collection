from flask import Flask

app = Flask(__name__)
 

@app.route('/')
def home():
    return "This is homepage"

@app.route('/about')
def about():
    return "This is about page"

@app.route('/services')
def services():
    return "This is services page"

@app.route('/username/<username>')
def show_username(username):
    return f"This is {username} profile"


if __name__ == '__main':
    app.run(debug=True)