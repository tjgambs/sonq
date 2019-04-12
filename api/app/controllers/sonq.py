from flask import abort
from flask import Blueprint
from flask import jsonify
from flask import request

from app import db
from app.models.queue import Queue
from app.models.device import Device
from app.models.guests import Guests
from app.models.party import Party

from sqlalchemy.exc import IntegrityError
from sqlalchemy.sql.expression import func
from datetime import datetime

mod = Blueprint("sonq", __name__, url_prefix="/sonq")


@mod.route('/queue/<party_id>', methods=["GET"])
def get_queue(party_id):
    ''' Get songs from the queue '''
    q = (db.session.query(Queue)
         .filter(Queue.party_id == party_id)
         .filter(Queue.status <= 1)
         .filter(Queue.deleted_at == None)
         .order_by(Queue.position.asc()))
    payload = [x.serialize for x in q.all()]
    return jsonify(payload)

@mod.route('/queue', methods=["POST"])
def post_queue():
    ''' Add song to the queue '''
    try:
        party_id = request.json.get('party_id')
        q = db.session.query(func.max(Queue.position)).filter(Queue.party_id == party_id)
        result = q.first()
        position = 0 if result[0] is None else result[0] + 1
        queue_obj = Queue()
        queue_obj.party_id = party_id
        queue_obj.name = request.json.get('name')
        queue_obj.artist = request.json.get('artist')
        queue_obj.album = request.json.get('album')
        queue_obj.duration = request.json.get('duration')
        queue_obj.duration_in_seconds = request.json.get('duration_in_seconds')
        queue_obj.image_url = request.json.get('image_url')
        queue_obj.song_url = request.json.get('song_url')
        queue_obj.created_at = datetime.now()
        queue_obj.position = position
        queue_obj.added_by = request.json.get('added_by')
        queue_obj.status = 0

        db.session.add(queue_obj)
        db.session.commit()
        return jsonify({'message': 'Success'})
    except Exception as e:
        print(e)
        db.session.rollback()
        abort(400)

@mod.route('/queue', methods=["PUT"])
def put_queue():
    ''' Modify status of the song passed '''
    try:
        song_id = request.json.get('id')
        party_id = request.json.get('party_id')
        q = (db.session.query(Queue)
                .filter(Queue.id == song_id)
                .filter(Queue.party_id == party_id))
        result = q.first()
        if not result:
            abort(400)
        
        result.status = request.json.get('status')
        db.session.commit()
        return jsonify({'message': 'Success'})
    except:
        db.session.rollback()
        abort(400)

@mod.route('/queue', methods=["DELETE"])
def delete_queue():
    ''' Set the deleted at field for a song in the queue '''
    try:
        song_id = request.json.get('id')
        party_id = request.json.get('party_id')
        q = (db.session.query(Queue)
                .filter(Queue.id == song_id)
                .filter(Queue.party_id == party_id))
        result = q.first()
        if not result:
            abort(400)
        
        result.deleted_at = datetime.now()
        db.session.commit()
        return jsonify({'message': 'Success'})
    except:
        db.session.rollback()
        abort(400)



@mod.route('/device/<device_id>', methods=["GET"])
def get_device(device_id):
    ''' Get device information '''
    q = (db.session.query(Device)
         .filter(Device.id == device_id))
    payload = q.first()
    if not payload:
        abort(400)
    return jsonify(payload.serialize)

@mod.route('/device', methods=["POST"])
def post_device():
    ''' Register a new device '''
    try:
        device_obj = Device()
        device_obj.id = request.json.get('id')
        device_obj.username = request.json.get('username')
        device_obj.created_at = datetime.now()
        db.session.add(device_obj)
        db.session.commit()
        return jsonify({'message': 'Success'})
    except:
        db.session.rollback()
        abort(400)

@mod.route('/device', methods=["PUT"])
def put_device():
    ''' Modify name of device '''
    try:
        device_id = request.json.get('id')
        q = (db.session.query(Device)
                .filter(Device.id == device_id))
        result = q.first()
        if not result:
            abort(400)
        
        result.username = request.json.get('username')
        db.session.commit()
        return jsonify({'message': 'Success'})
    except:
        db.session.rollback()
        abort(400)



@mod.route('/party/<party_id>', methods=["GET"])
def get_party(party_id):
    ''' Get the party's information '''
    q = (db.session.query(Party)
         .filter(Party.id == party_id))
    payload = q.first()
    if not payload:
        abort(400)
    return jsonify(payload.serialize)

@mod.route('/party', methods=["POST"])
def post_party():
    ''' Create a new party '''
    try:
        party_obj = Party()
        party_obj.id = request.json.get('id')
        party_obj.created_by = request.json.get('created_by')
        party_obj.name = request.json.get('name')
        party_obj.created_at = datetime.now()
        db.session.add(party_obj)
        db.session.commit()
        return jsonify({'message': 'Success'})
    except:
        db.session.rollback()
        abort(400)

@mod.route('/party', methods=["PUT"])
def put_party():
    ''' Update name of the party or end the party '''
    try:
        party_id = request.json.get('id')
        q = (db.session.query(Party)
                .filter(Party.id == party_id))
        result = q.first()
        if not result:
            abort(400)
        
        result.name = request.json.get('name')
        db.session.commit()
        return jsonify({'message': 'Success'})
    except:
        db.session.rollback()
        abort(400)

@mod.route('/party', methods=["DELETE"])
def delete_party():
    ''' Update name of the party or end the party '''
    try:
        party_id = request.json.get('id')
        q = (db.session.query(Party)
                .filter(Party.id == party_id))
        result = q.first()
        if not result:
            abort(400)
        
        result.ended_at = datetime.now()
        db.session.commit()
        return jsonify({'message': 'Success'})
    except:
        db.session.rollback()
        abort(400)



@mod.route('/guests/<party_id>', methods=["GET"])
def get_guests(party_id):
    ''' Get all of the guests in this party'''
    q = (db.session.query(Guests)
         .filter(Guests.party_id == party_id)
         .order_by(Guests.joined_at.asc()))
    payload = [x.serialize for x in q.all()]
    return jsonify(payload)

@mod.route('/guests', methods=["POST"])
def post_guests():
    ''' Register a guest as a part of the party'''
    try:
        party_id = request.json.get('party_id')
        device_id = request.json.get('device_id')
        q = (db.session.query(Guests)
                .filter(Guests.party_id == party_id)
                .filter(Guests.device_id == device_id))
        guest_obj = q.first()
        if not guest_obj:
            guest_obj = Guests()
        guest_obj.device_id = device_id
        guest_obj.party_id = party_id
        guest_obj.joined_at = datetime.now()
        guest_obj.left_at = None
        db.session.add(guest_obj)
        db.session.commit()
        return jsonify({'message': 'Success'})
    except Exception as e:
        print(e)
        db.session.rollback()
        abort(400)

@mod.route('/guests', methods=["DELETE"])
def delete_guests():
    ''' Remove the guest from the party '''
    try:
        party_id = request.json.get('party_id')
        device_id = request.json.get('device_id')
        q = (db.session.query(Guests)
                .filter(Guests.party_id == party_id)
                .filter(Guests.device_id == device_id))
        result = q.first()
        if not result:
            abort(400)
        
        result.left_at = datetime.now()
        db.session.commit()
        return jsonify({'message': 'Success'})
    except:
        db.session.rollback()
        abort(400)
