from app import db


class Device(db.Model):

    __tablename__ = "device"

    id = db.Column(db.String, primary_key=True)
