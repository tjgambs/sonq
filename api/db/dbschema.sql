CREATE TABLE device (
    id text PRIMARY KEY,
    username text
);

CREATE UNIQUE INDEX device_pkey ON device(id text_ops);


CREATE TABLE party (
    id text PRIMARY KEY,
    created_by text REFERENCES device(id) ON DELETE CASCADE,
    name text,
    created_at timestamp without time zone DEFAULT now()
);

CREATE UNIQUE INDEX party_pkey ON party(id text_ops);


CREATE TABLE queue (
    "partyID" text REFERENCES party(id) ON DELETE CASCADE,
    name text,
    artist text,
    duration text,
    "durationInSeconds" double precision,
    "imageURL" text,
    "songURL" text,
    created_at timestamp without time zone DEFAULT now(),
    position integer,
    added_by text REFERENCES device(id) ON DELETE CASCADE,
    is_playing boolean DEFAULT false,
    CONSTRAINT queue_pkey PRIMARY KEY ("partyID", "songURL")
);

CREATE UNIQUE INDEX queue_pkey ON queue("partyID" text_ops,"songURL" text_ops);
