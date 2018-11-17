import os

_basedir = os.path.abspath(os.path.dirname(__file__))

SQLALCHEMY_DATABASE_URI = "postgres://postgres:Jbu6xi8jmf2oy00g@35.188.8.242:5432/titan"
SQLALCHEMY_COMMIT_ON_TEARDOWN = True
SQLALCHEMY_TRACK_MODIFICATIONS = False
SQLALCHEMY_POOL_TIMEOUT	= 10
