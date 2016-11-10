CREATE TABLE student (
  student_id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  login VARCHAR(80) NOT NULL,
  pass VARCHAR(80) NOT NULL
) ENGINE=INNODB;

INSERT INTO student(login, pass) VALUES('test','test');
INSERT INTO student(login, pass) VALUES('personlighetvt09','bfi');

