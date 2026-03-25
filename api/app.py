from flask import Flask, jsonify, request
import os
import socket
import time
from datetime import datetime

app = Flask(__name__)

APP_VERSION = "1.0.0"
START_TIME = time.time()

@app.route('/health')
def health():
    uptime_seconds = int(time.time() - START_TIME)
    uptime_minutes = uptime_seconds // 60
    uptime_hours = uptime_minutes // 60
    
    return jsonify({
        "status": "healthy",
        "container": "flask-api-service",
        "version": APP_VERSION,
        "hostname": socket.gethostname(),
        "uptime": {
            "seconds": uptime_seconds,
            "minutes": uptime_minutes,
            "hours": uptime_hours,
            "formatted": f"{uptime_hours}h {uptime_minutes % 60}m {uptime_seconds % 60}s"
        },
        "timestamp": datetime.utcnow().isoformat(),
        "python_version": os.sys.version.split()[0]
    })

@app.route('/')
def index():
    return jsonify({
        "message": "This is the Flask API container",
        "service": "multi-container-demo",
        "version": APP_VERSION
    })

@app.route('/api/info')
def info():
    return jsonify({
        "name": "Multi-Container Demo API",
        "version": APP_VERSION,
        "framework": "Flask",
        "container": "Docker",
        "platform": "Railway",
        "hostname": socket.gethostname()
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)