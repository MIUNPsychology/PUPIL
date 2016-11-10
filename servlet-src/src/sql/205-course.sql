CREATE TABLE course (
  course_id INTEGER PRIMARY KEY AUTO_INCREMENT,
  teacher_id INTEGER NOT NULL,
  code VARCHAR(80),
  name VARCHAR(80),
  description VARCHAR(80),
  FOREIGN KEY (teacher_id) REFERENCES teacher(teacher_id) ON DELETE CASCADE
) ENGINE=INNODB;

INSERT INTO course(teacher_id,code,name,description) VALUES(1,'p001','PUPIL','testkurs');

