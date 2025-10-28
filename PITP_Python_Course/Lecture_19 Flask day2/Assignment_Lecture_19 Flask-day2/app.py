from flask import Flask, render_template, request

app = Flask(__name__)

@app.route('/')
def home():
    return "This is Homepage. Go to /login to try the form."

@app.route('/login', methods=['GET', 'POST'])
def login():
    message = ""
    username = ""
    password = ""
    submitted_data = ""

    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')

        if username and password:
            message = f"Welcome {username}!"
            # ✅ Show all submitted data
            submitted_data = f"""
            <h3>Submitted Data:</h3>
            <p><strong>Username:</strong> {username}</p>
            <p><strong>Password:</strong> {password}</p>
            """
        else:
            message = "Error: Please fill in both fields."

    return render_template('login.html', message=message, username=username, submitted_data=submitted_data)

if __name__ == '__main__':
    app.run(debug=True)
