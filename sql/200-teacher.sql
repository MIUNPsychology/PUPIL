DROP TABLE IF EXISTS teacher;

CREATE TABLE teacher (
  teacher_id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  login VARCHAR(80) NOT NULL,
  pass VARCHAR(80)
) ENGINE=INNODB;

INSERT INTO teacher(login,pass) VALUES("teacher",null);

