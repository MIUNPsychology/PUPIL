DROP TABLE IF EXISTS testgrupp;

CREATE TABLE testgrupp (
  testgrupp_id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  namn VARCHAR(80),
  beskrivning VARCHAR(80)
) ENGINE=INNODB;

INSERT INTO testgrupp(namn,beskrivning) VALUES('student','students');
INSERT INTO testgrupp(namn,beskrivning) VALUES('teacher','teachers');

