from flask import abort
from flask import Blueprint
from flask import jsonify
from flask import request

from app import db
from app.utils import prepare_json_response
from app.models.queue import Queue

import spotipy
from spotipy.oauth2 import SpotifyClientCredentials

client_credentials_manager = SpotifyClientCredentials(client_id='a9f554e8bb984585a1113624550330bb', 
													  client_secret='5ba840288aad4545a879d0dad451720a', 
													  proxies=None)
spotify = spotipy.Spotify(client_credentials_manager=client_credentials_manager)


mod = Blueprint("v1_titan", __name__, url_prefix="/v1/titan")


@mod.route("/add_song", methods=["POST"])
def add_song():
    db.session.add(Queue(**request.json))
    db.session.commit()
    return jsonify(
        prepare_json_response(
            message="OK",
            success=True
        )
    )


@mod.route("/get_queue/<party_id>", methods=["GET"])
def get_queue(party_id):
    q = db.session.query(Queue).filter(Queue.party_id == party_id)
    payload = [q.song_id for q in q.all()]
    data = {'results': payload}
    return jsonify(
        prepare_json_response(
            message="OK",
            success=True,
            data=data
        )
    )

@mod.route("/get_parties", methods=["GET"])
def get_parties():
    q = db.session.query(Queue.party_id).group_by(Queue.party_id)
    payload = [q.party_id for q in q.all()]
    data = {'results': payload}
    return jsonify(
        prepare_json_response(
            message="OK",
            success=True,
            data=data
        )
    )


@mod.route("/delete_song", methods=["DELETE"])
def delete_song():
    req_content = request.json
    db.session.query(Queue).filter(
        (Queue.party_id == req_content['party_id'])
        & (Queue.song_id == req_content['song_id'])).delete()
    db.session.commit()
    return jsonify(
        prepare_json_response(
            message="OK",
            success=True
        )
    )

@mod.route("/join_party/<party_id>", methods=["GET"])
def join_party(party_id):
    q = db.session.query(Queue).filter(Queue.party_id == party_id)
    if len(q.all()) :
    	data = {'party_exists' : True}
    else :
    	data = {'party_exists' : False}
    return jsonify(
        prepare_json_response(
            message="OK",
            success=True,
            data=data
        )
    )

@mod.route("/spotify_search/<query>", methods=["GET"])
def spotify_search(query):
    results = spotify.search(q=query, type='track')
    for item in results['tracks']['items']:
    	print 'Song Name: ' + item['name'] + '  Artist: ' + item['artists'][0]['name'] + '  Song ID: ' + item['id'] + '\n'

    return jsonify(
        prepare_json_response(
            message="OK",
            success=True,
            #data=data
        )
    )
