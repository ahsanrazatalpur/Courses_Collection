from flask import Flask , render_template , request

app = Flask(__name__)


@app.route('/')
def home():
    return render_template('index.html')


@app.route('/contact')
def contact():
    return render_template('contact.html')
@app.route('/contact-process', methods=['GET', 'POST'])
def contact_process():
    name = request.form.get('name')
    email = request.form.get('email')
    phone = request.form.get('phone')
    return f"<p>Your data has been submitted:<ul><li> Name : {name}</li><li> Email : {email}</li><li> Phone : {phone}</li></ul></p>"





if __name__ == "__main__":
    app.run(debug=True)