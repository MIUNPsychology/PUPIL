DROP TABLE IF EXISTS testresultat;

CREATE TABLE testresultat (
  testresultat_id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  person_id INTEGER NOT NULL,
  testomgang INTEGER,
  obs1 INTEGER,
  obs2 INTEGER,
  obs3 INTEGER,
  obs4 INTEGER,
  obs5 INTEGER
) ENGINE=INNODB;


