from flask import Flask

# Create a Flask application instance
# 'app' is the main Flask object that runs your web application
app = Flask(__name__)

# Define a route
# @app.route("/") is a decorator that tells Flask:
# "When someone visits the home page (http://127.0.0.1:5000/), run the function 'home'"
@app.route("/")
def home():
    # Return a response to the browser
    return "Hello World! Welcome to my first app"

# Run this application
if __name__ == '__main__':  
    # Only run this block if the script is executed directly
    # app.run(debug=True) starts the Flask development server:
    # - debug=True enables automatic reload when code changes
    # - shows detailed errors if something goes wrong
    app.run(debug=True)
