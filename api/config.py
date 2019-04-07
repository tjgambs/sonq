import os

_basedir = os.path.abspath(os.path.dirname(__file__))

# SQLALCHEMY_DATABASE_URI = "postgresql://root:V8*FjNZTq5{@songq.c7m8zkgs7cmh.us-east-2.rds.amazonaws.com/songq"
SQLALCHEMY_DATABASE_URI = "postgresql://tim@localhost:5432/sonq"
SQLALCHEMY_COMMIT_ON_TEARDOWN = True
SQLALCHEMY_TRACK_MODIFICATIONS = False
SQLALCHEMY_POOL_TIMEOUT	= 10
