from app import db
from app.models.device import Device
from app.utils import serialize_datetime


class Guests(db.Model):

    __tablename__ = "guests"

    device_id = db.Column(db.String, db.ForeignKey('device.id'), primary_key=True)
    device_id_key = db.relationship(Device, backref='guests', foreign_keys=device_id)
    party_id = db.Column(db.String, db.ForeignKey('party.id'))
    joined_at = db.Column(db.Date)
    left_at = db.Column(db.Date)

    @property
    def serialize(self):
        return {
            'username': self.device_id_key.username,
            'party_id': self.party_id,
            'joined_at': serialize_datetime(self.joined_at),
            'left_at': serialize_datetime(self.left_at)
        }
