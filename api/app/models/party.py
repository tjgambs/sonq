from app import db
from .device import Device
import datetime


class Party(db.Model):

    __tablename__ = "party"

    id = db.Columnid = db.Column(db.String, primary_key=True)
    created_by = db.Column(db.String, db.ForeignKey('device.id', ondelete='CASCADE'))
    created_at = db.Column(db.Date, default=datetime.datetime.utcnow)
    created_by_key = db.relationship(Device, backref='party', foreign_keys=created_by)

    @property
    def serialize(self):
        return {'id': self.id,
                'created_by': self.created_by_key.username,
                'created_at': self.created_at
                }
