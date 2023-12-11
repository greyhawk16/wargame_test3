#-*-coding:utf-8-*-
# mini-CTF SSTI 문제


from flask import Flask, request, render_template, render_template_string
import os

app = Flask(__name__)
app.secret_key = os.urandom(16)
app.config['MAX_CONTENT_LENGTH'] = 80 * 1024 * 1024

@app.route("/", methods=['GET', 'POST'])
def index():
	if request.method == 'POST':
		inp = request.form.get("keyword")
		return render_template_string(inp)
	return render_template("home.html")


# @app.route("/result")
# def solu():
# 	data = request.form.get("keyword")
# 	return data


if __name__ == "__main__":
	app.run(host="0.0.0.0", port=5000, debug=True)
	# except Exception as ex:2
	# 	pass