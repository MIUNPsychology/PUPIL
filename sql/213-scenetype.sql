DROP TABLE IF EXISTS scenetype;

CREATE TABLE scenetype (
  scenetype_id INTEGER NOT NULL PRIMARY KEY,
  mnemonic VARCHAR(30) NOT NULL,
  description VARCHAR(250) NOT NULL
) ENGINE=INNODB;

INSERT INTO scenetype(scenetype_id,mnemonic,description) VALUES(1,'static_image','blah');
INSERT INTO scenetype(scenetype_id,mnemonic,description) VALUES(2,'static_category_random_image','blah');
INSERT INTO scenetype(scenetype_id,mnemonic,description) VALUES(3,'select_option_static_image','blah');
INSERT INTO scenetype(scenetype_id,mnemonic,description) VALUES(4,'select_option_random_image','blah');
INSERT INTO scenetype(scenetype_id,mnemonic,description) VALUES(5,'text','blah');

