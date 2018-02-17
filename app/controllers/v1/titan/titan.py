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


@mod.route("/get_next_song/<deviceID>", methods=["GET"])
def get_queue(deviceID):
    q = (db.session.query(Queue)
         .filter(Queue.deviceID == deviceID)
         .order_by(Queue.created_at.asc()))
    data = {'results': q.first().serialize if q.first() else None}
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
        (Queue.deviceID == req_content['deviceID'])
        & (Queue.songURL == req_content['songURL'])).delete()
    db.session.commit()
    return jsonify(
        prepare_json_response(
            message="OK",
            success=True
        )
    )


@mod.route("/register_device/<deviceID>", methods=["GET"])
def register_device(deviceID):
    message = "OK"
    try:
        db.session.add(Device(id=deviceID))
        db.session.commit()
    except IntegrityError:
        message = "PARTY ALREADY EXISTS"
        db.session.close()
    return jsonify(
        prepare_json_response(
            message=message,
            success=True
        )
    )


@mod.route("/join_party/<deviceID>", methods=["GET"])
def join_party(deviceID):
    q = db.session.query(Device).filter(Device.id == deviceID)
    data = {'party_exists': bool(len(q.all()))}
    return jsonify(
        prepare_json_response(
            message="OK",
            success=True,
            data=data
        )
    )
