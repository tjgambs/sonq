from app import db
from app.utils import serialize_datetime


class Device(db.Model):

    __tablename__ = "device"

    id = db.Column(db.String, primary_key=True)
    username = db.Column(db.String)
    created_at = db.Column(db.Date)

    @property
    def serialize(self):
        return {
            'id': self.id,
            'username': self.username,
            'created_at': serialize_datetime(self.created_at)
        }
