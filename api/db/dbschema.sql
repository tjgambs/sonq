CREATE TABLE device (
    id varchar primary key,
    username varchar,
    created_at timestamp
);

CREATE TABLE party (
    id varchar(8) primary key,
    created_by varchar references device(id),
    name varchar,
    created_at timestamp,
    ended_at timestamp
);
CREATE INDEX ON party (created_by);

CREATE TABLE guests (
    device_id varchar references device(id),
    party_id varchar(8) references party(id),
    joined_at timestamp,
    left_at timestamp
);
CREATE INDEX ON guests (party_id);

CREATE TABLE queue (
    party_id varchar(8) references party(id),
    name varchar,
    artist varchar,
    album varchar,
    duration varchar,
    duration_in_seconds double precision,
    image_url varchar,
    song_url varchar,
    created_at timestamp,
    deleted_at timestamp,
    position integer,
    added_by varchar references device(id),
    status integer
);
CREATE INDEX ON queue (party_id);
