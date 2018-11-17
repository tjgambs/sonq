from app import db
from .device import Device
import datetime


class Queue(db.Model):

    __tablename__ = "queue"

    partyID = db.Column(db.String, db.ForeignKey(
        'device.id', ondelete='CASCADE'), primary_key=True)
    name = db.Column(db.String)
    artist = db.Column(db.String)
    duration = db.Column(db.String)
    durationInSeconds = db.Column(db.Float)
    imageURL = db.Column(db.String)
    songURL = db.Column(db.String, primary_key=True)
    created_at = db.Column(db.Date, default=datetime.datetime.utcnow)
    position = db.Column(db.Integer)
    added_by = db.Column(db.String, db.ForeignKey('device.id', ondelete='CASCADE'))
    added_by_key = db.relationship(Device, backref='queue', foreign_keys=added_by)

    @property
    def serialize(self):
        return {'partyID': self.partyID,
                'name': self.name,
                'artist': self.artist,
                'duration': self.duration,
                'durationInSeconds': self.durationInSeconds,
                'imageURL': self.imageURL,
                'songURL': self.songURL,
                'position:': self.position,
                'added_by': self.added_by_key.username}
