from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello Loco! Welcome to my multi-stage scalable Docker Kubernetes application. Its designed for seamless deployment and scaling in Kubernetes.'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
