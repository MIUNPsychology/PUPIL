CREATE TABLE category (
  category_id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  project_id INTEGER NOT NULL,
  name VARCHAR(80) UNIQUE,
  FOREIGN KEY (project_id) REFERENCES project(project_id) ON DELETE CASCADE
) ENGINE=INNODB;

INSERT INTO category (project_id, name) VALUES(1,"test_neutral");
INSERT INTO category (project_id, name) VALUES(1,"test_farlig");

