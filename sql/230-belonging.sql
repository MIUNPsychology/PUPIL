DROP TABLE IF EXISTS belonging;

CREATE TABLE belonging (
  course_id INTEGER NOT NULL,
  student_id INTEGER NOT NULL,
  FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES student(student_id) ON DELETE CASCADE,
  PRIMARY KEY (course_id,student_id)
) ENGINE=INNODB;

