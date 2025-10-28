from flask import Flask, render_template, request

app = Flask(__name__)

@app.route('/')
def home():
    return "This is Homepage. Go to /signup to register."

@app.route('/signup')
def signup():
    return render_template('signup.html')

@app.route('/signup-process', methods=['POST'])
def signup_process():
    # Get form data
    name = request.form.get('name')
    father_name = request.form.get('father_name')
    email = request.form.get('email')
    phone = request.form.get('phone')
    
    # Render the same template but pass the submitted data
    return render_template(
        'signup.html', 
        submitted=True, 
        name=name, 
        father_name=father_name, 
        email=email, 
        phone=phone
    )

if __name__ == "__main__":
    app.run(debug=True)
