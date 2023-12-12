#-*-coding:utf-8-*-
# mini-CTF의 SSTI 참고
# SSTI 취약점이 있는 HTML 시물레이터
# home.html: html 태그를 입력받는 페이지


from flask import Flask, request, render_template, render_template_string
import os


app = Flask(__name__)
app.secret_key = os.urandom(16)
app.config['MAX_CONTENT_LENGTH'] = 80 * 1024 * 1024


@app.route("/", methods=['GET', 'POST'])
def index():
	if request.method == 'POST':
		inp = request.form.get("keyword")     # 입력받은 html 코드 및 태그
		return render_template_string(inp)    # inp를 html로 인식 후, 브라우저에 표시
	return render_template("home.html")


if __name__ == "__main__":
	app.run(host="0.0.0.0", port=5000, debug=True)
	# except Exception as ex:2
	# 	pass