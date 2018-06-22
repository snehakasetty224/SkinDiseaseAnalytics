from flask import Flask
app = Flask(__name__)

@app.route('/hi')
def hello_world():
	print('hi')
	return 'hi pooja'

if __name__ == "__main__":
     app.run(host="0.0.0.0", port=5000)
