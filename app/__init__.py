from flask_sqlalchemy import SQLAlchemy
from flask import Flask, request

app = Flask(__name__)
app.config.from_object("config")

db = SQLAlchemy(app)


import spotipy
from spotipy.oauth2 import SpotifyClientCredentials

spotify_client = spotipy.Spotify(
    client_credentials_manager=SpotifyClientCredentials(
        client_id='a9f554e8bb984585a1113624550330bb',
        client_secret='5ba840288aad4545a879d0dad451720a',
        proxies=None))


from app.controllers import default
from app.controllers.v1.titan import titan

app.register_blueprint(default.mod)
app.register_blueprint(titan.mod)


def add_cors_headers(response):
    response.headers['Access-Control-Allow-Origin'] = '*'
    if request.method == 'OPTIONS':
        response.headers[
            'Access-Control-Allow-Methods'] = 'DELETE, GET, POST, PUT'
        headers = request.headers.get('Access-Control-Request-Headers')
        if headers:
            response.headers['Access-Control-Allow-Headers'] = headers
    if request.method == 'DELETE':
        response.headers[
            'Access-Control-Allow-Methods'] = 'DELETE, GET, POST, PUT'
        headers = request.headers.get('Access-Control-Request-Headers')
        if headers:
            response.headers['Access-Control-Allow-Headers'] = headers
    return response
app.after_request(add_cors_headers)
