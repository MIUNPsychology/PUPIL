DROP TABLE IF EXISTS permission;

CREATE TABLE permission (
  permission_id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  student_id INTEGER NOT NULL,
  project_id INTEGER NOT NULL,
  FOREIGN KEY (student_id) REFERENCES student(student_id) ON DELETE CASCADE,
  FOREIGN KEY (project_id) REFERENCES project(project_id) ON DELETE CASCADE
) ENGINE=INNODB;

INSERT INTO permission(student_id, project_id) VALUES(1,1);


