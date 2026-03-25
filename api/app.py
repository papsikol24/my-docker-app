from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)

@app.route('/health')
def health():
    return jsonify({
        "status": "healthy",
        "container": "api-service",
        "hostname": socket.gethostname(),
        "version": "1.0.0"
    })

@app.route('/')
def index():
    return jsonify({
        "message": "This is the API container",
        "service": "flask-api"
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)