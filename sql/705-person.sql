DROP TABLE IF EXISTS person;

CREATE TABLE person (
  person_id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  testgrupp_id INTEGER,
  fornamn VARCHAR(80),
  efternamn VARCHAR(80),
  kon INTEGER DEFAULT 0,
  langd INTEGER,
  skostorlek INTEGER
) ENGINE=INNODB;


