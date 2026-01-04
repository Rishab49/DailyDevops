"""
Basic flask app
"""

from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    """
    basic function to return hello world
    """
    return "Hello from Flask inside Docker!"

@app.route('/health/')
def health():
    """
    basic function of health check
    """
    return jsonify(status="UP"), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
