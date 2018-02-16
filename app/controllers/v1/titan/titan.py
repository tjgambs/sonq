from flask import abort
from flask import Blueprint
from flask import jsonify
from flask import request

from app import db
from app import spotify_client
from app.utils import prepare_json_response
from app.models.queue import Queue


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
    data = {'party_exists': bool(len(q.all()))}
    return jsonify(
        prepare_json_response(
            message="OK",
            success=True,
            data=data
        )
    )


@mod.route("/spotify_search/<query>", methods=["GET"])
def spotify_search(query):
    results = spotify_client.search(q=query, type='track', limit=50)
    data = [{'uri': i['uri'],
             'name':i['name'],
             'artist':i['artists'][0]['name']}
            for i in results['tracks']['items']]
    return jsonify(
        prepare_json_response(
            message="OK",
            success=True,
            data=data
        )
    )
