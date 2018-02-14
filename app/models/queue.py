from app import db


class Queue(db.Model):

    __tablename__ = "queue"

    party_id = db.Column(db.String, primary_key=True)
    song_id = db.Column(db.String, primary_key=True)
