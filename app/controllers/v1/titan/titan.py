from flask import abort
from flask import Blueprint
from flask import jsonify
from flask import request

from app import db
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
