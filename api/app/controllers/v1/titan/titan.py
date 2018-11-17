from flask import abort
from flask import Blueprint
from flask import jsonify
from flask import request

from app import db
from app import spotify_client
from app.utils import prepare_json_response
from app.models.queue import Queue
from app.models.device import Device

from sqlalchemy.exc import IntegrityError


mod = Blueprint("v1_titan", __name__, url_prefix="/v1/titan")


@mod.route("/add_song", methods=["POST"])
def add_song():
    message = "OK"
    try:
        q = (db.session.query(Queue)
             .filter(Queue.partyID == request.json['partyID'])
             .order_by(Queue.position.desc()))
        last_position = q.first().position if q.first() else -1
        request.json['position'] = last_position + 1
        db.session.add(Queue(**request.json))
        db.session.commit()
    except IntegrityError:
        message = "SONG IN QUEUE"
        db.session.close()
    return jsonify(
        prepare_json_response(
            message=message,
            success=True
        )
    )


@mod.route("/get_next_song/<partyID>", methods=["GET"])
def get_next_song(partyID):
    q = (db.session.query(Queue)
         .filter(Queue.partyID == partyID)
         .order_by(Queue.position.asc()))
    data = {'results': q.first().serialize if q.first() else None}
    return jsonify(
        prepare_json_response(
            message="OK",
            success=True,
            data=data
        )
    )


@mod.route("/get_queue/<partyID>", methods=["GET"])
def get_queue(partyID):
    q = (db.session.query(Queue)
         .filter(Queue.partyID == partyID)
         .order_by(Queue.position.asc()))
    payload = [x.serialize for x in q.all()]
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
        (Queue.partyID == req_content['partyID'])
        & (Queue.songURL == req_content['songURL'])).delete()
    db.session.commit()
    return jsonify(
        prepare_json_response(
            message="OK",
            success=True
        )
    )

@mod.route("/join_party/<partyID>", methods=["GET"])
def join_party(partyID):
    q = db.session.query(Device).filter(Device.id == partyID)
    data = {'party_exists': bool(len(q.all()))}
    return jsonify(
        prepare_json_response(
            message="OK",
            success=True,
            data=data
        )
    )

@mod.route("/reorder_queue", methods=["POST"])
def reorder_queue():
    for idx, s in enumerate(request.json['songs']):
        q = (db.session.query(Queue).filter(Queue.partyID == request.json['partyID']).filter(Queue.songURL == s))
        q.first().position = idx
    db.session.commit()
    return jsonify(
        prepare_json_response(
            message="OK",
            success=True
        )
    )

@mod.route("/update_username/<deviceID>", methods=["POST"])
def update_username(deviceID):
    username = request.json['username']
    q = db.session.query(Device).filter(Device.id == deviceID)
    # DeviceId Exists.
    if q.first():
        q.first().username = username
    # DeviceId does not exist, create it now.
    else:
        db.session.add(Device(id=deviceID, username=username))
    db.session.commit()
    return jsonify(
        prepare_json_response(
            message="OK",
            success=True
        )
    )

