from flask import Flask, render_template


app = Flask(__name__)


@app.route("/hello/<username>")
def greet(username):
    return render_template("index.html", name = username)

@app.route('/welcome')
def welcome():
    return "We are warm welcoming you 😇"


@app.route('/square')
def square():
    number = 4
    return str(number * number)


@app.route('/repeat')
def repeat():
    name = "Ahsan"
    repeated_name = (name + " " )* 10
    return repeated_name




if (__name__) == "__main__":
    app.run(debug = True)