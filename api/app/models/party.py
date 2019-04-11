from app import db
from app.models.device import Device
from app.utils import serialize_datetime


class Party(db.Model):

    __tablename__ = "party"

    id = db.Column(db.String, primary_key=True)
    created_by = db.Column(db.String, db.ForeignKey('device.id'))
    created_by_key = db.relationship(Device, backref='party', foreign_keys=created_by)
    name = db.Column(db.String)
    created_at = db.Column(db.Date)
    ended_at = db.Column(db.Date)

    @property
    def serialize(self):
        return {
            'id': self.id,
            'created_by': self.created_by_key.username,
            'name': self.name,
            'created_at': serialize_datetime(self.created_at),
            'ended_at': serialize_datetime(self.ended_at)
        }
