from app import db
from app.models.device import Device
from app.utils import serialize_datetime


class Queue(db.Model):

    __tablename__ = "queue"

    id = db.Column(db.Integer, primary_key=True)
    party_id = db.Column(db.String, db.ForeignKey('device.id'))
    name = db.Column(db.String)
    artist = db.Column(db.String)
    album = db.Column(db.String)
    duration = db.Column(db.String)
    duration_in_seconds = db.Column(db.Float)
    image_url = db.Column(db.String)
    song_url = db.Column(db.String)
    created_at = db.Column(db.Date)
    deleted_at = db.Column(db.Date)
    position = db.Column(db.Integer)
    added_by = db.Column(db.String, db.ForeignKey('device.id'))
    added_by_key = db.relationship(Device, backref='queue', foreign_keys=added_by)
    status = db.Column(db.Integer)

    @property
    def serialize(self):
        return {
            'party_id': self.party_id,
            'name': self.name,
            'artist': self.artist,
            'album': self.album,
            'duration': self.duration,
            'duration_in_seconds': self.duration_in_seconds,
            'image_url': self.image_url,
            'song_url': self.song_url,
            'created_at': serialize_datetime(self.created_at),
            'deleted_at': serialize_datetime(self.deleted_at),
            'position': self.position,
            'added_by': self.added_by_key.username,
            'status': self.status
        }
