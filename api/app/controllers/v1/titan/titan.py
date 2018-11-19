from flask import abort
from flask import Blueprint
from flask import jsonify
from flask import request

from app import db
from app import spotify_client
from app.utils import prepare_json_response
from app.models.queue import Queue
from app.models.device import Device
from app.models.party import Party

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
        db.session.rollback()
        db.session.close()
        abort(409)
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
    data = {'queue': payload}
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
    q = db.session.query(Party).filter(Party.id == partyID)
    party_exists = bool(q.first())
    created_by = None
    if party_exists:
        created_by = q.first().created_by
    data = {'party_exists': party_exists, 'created_by': created_by}
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
    # DeviceId does not exist
    else:
        db.session.add(Device(id=deviceID, username=username))
    db.session.commit()
    return jsonify(
        prepare_json_response(
            message="OK",
            success=True
        )
    )

@mod.route("/create_party", methods=["POST"])
def create_party():
    party_id = request.json['party_id']
    device_id = request.json['device_id']
    data = {"party_id": party_id}
    # Create device
    q = db.session.query(Device).filter(Device.id == device_id)
    # DeviceId does not exist, create it now.
    if not q.first():
        db.session.add(Device(id=device_id))

    # Create the party
    db.session.add(Party(id=party_id, created_by=device_id))
    try:
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        db.session.close()
        abort(409)
    return jsonify(
        prepare_json_response(
            message="OK",
            success=True,
            data=data
        )
    )

@mod.route("/check_in_queue/<partyID>", methods=["POST"])
def check_in_queue(partyID):
    search_results = request.json['search_results']
    in_queue = []
    for song in search_results:
        idx = song['idx']
        song_url = song['song_url']
        q = db.session.query(Queue).filter(Queue.partyID == partyID).filter(Queue.songURL == song_url)
        if q.first():
            in_queue.append(idx)
    
    return jsonify(
        prepare_json_response(
            message="OK",
            success=True,
            data={"in_queue": in_queue}
        )
    )

@mod.route("/set_playing/<partyID>", methods=["PUT"])
def set_playing(partyID):
    song_url = request.json['song_url']
    is_playing = request.json['is_playing']

    q = db.session.query(Queue).filter(Queue.partyID == partyID).filter(Queue.songURL == song_url)
    if q.first():
        q.first().is_playing = is_playing
    else:
        abort(400)
    
    db.session.commit()

    return jsonify(
        prepare_json_response(
            message="OK",
            success=True
        )
    )
