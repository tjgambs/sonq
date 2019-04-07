
def serialize_datetime(dt):
    if dt:
        return int(dt.strftime("%s")) * 1000
    return None
