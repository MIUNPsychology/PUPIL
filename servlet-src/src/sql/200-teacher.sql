CREATE TABLE teacher (
  teacher_id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  login VARCHAR(80) NOT NULL,
  pass VARCHAR(80) NOT NULL
) ENGINE=INNODB;

INSERT INTO teacher(login,pass) VALUES("joepal","test");
INSERT INTO teacher(login,pass) VALUES("jens","jens");

