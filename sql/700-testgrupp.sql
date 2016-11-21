SET NAMES 'utf8';

CREATE TABLE testgrupp (
  testgrupp_id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  namn VARCHAR(80),
  beskrivning VARCHAR(80)
) ENGINE=INNODB;

INSERT INTO testgrupp(namn,beskrivning) VALUES('student','studenter på miun');
INSERT INTO testgrupp(namn,beskrivning) VALUES('teacher','lärare på miun');
INSERT INTO testgrupp(namn,beskrivning) VALUES('uteliggare','folk från kyrkparken');

