CREATE TABLE testcase (
  testcase_id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  project_id INTEGER NOT NULL,
  student_id INTEGER NOT NULL,
  FOREIGN KEY (project_id) REFERENCES project(project_id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES student(student_id) ON DELETE CASCADE
) ENGINE=INNODB;

