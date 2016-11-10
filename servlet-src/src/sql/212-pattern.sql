CREATE TABLE pattern (
  pattern_id INTEGER PRIMARY KEY NOT NULL,
  images INTEGER NOT NULL,
  mnemonic VARCHAR(30) NOT NULL,
  description VARCHAR(120) NOT NULL
) ENGINE=INNODB;

INSERT INTO pattern(pattern_id,images,mnemonic,description) VALUES(1,1,'single_centered','blah');
INSERT INTO pattern(pattern_id,images,mnemonic,description) VALUES(2,1,'single_stretched','blah');
INSERT INTO pattern(pattern_id,images,mnemonic,description) VALUES(3,2,'2x1','blah');
INSERT INTO pattern(pattern_id,images,mnemonic,description) VALUES(4,3,'3x1','blah');
INSERT INTO pattern(pattern_id,images,mnemonic,description) VALUES(5,3,'1+2','blah');
INSERT INTO pattern(pattern_id,images,mnemonic,description) VALUES(6,3,'2+1','blah');
INSERT INTO pattern(pattern_id,images,mnemonic,description) VALUES(7,4,'2x2','blah');
INSERT INTO pattern(pattern_id,images,mnemonic,description) VALUES(8,4,'4_as_plus','blah');
INSERT INTO pattern(pattern_id,images,mnemonic,description) VALUES(9,5,'5_as_x','blah');
INSERT INTO pattern(pattern_id,images,mnemonic,description) VALUES(10,5,'5_as_plus','blah');
INSERT INTO pattern(pattern_id,images,mnemonic,description) VALUES(11,6,'3x2','blah');
INSERT INTO pattern(pattern_id,images,mnemonic,description) VALUES(12,7,'3+1+3','blah');
INSERT INTO pattern(pattern_id,images,mnemonic,description) VALUES(13,8,'3+2+3','blah');
INSERT INTO pattern(pattern_id,images,mnemonic,description) VALUES(14,9,'3x3','blah');


