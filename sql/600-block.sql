DROP TABLE IF EXISTS block;

CREATE TABLE block (
  block_id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  project_id INTEGER NOT NULL,
  name VARCHAR(80) NOT NULL,
  random BOOLEAN DEFAULT 0,
  textfirst BOOLEAN DEFAULT 0,
  UNIQUE(project_id,name),
  FOREIGN KEY (project_id) REFERENCES project(project_id) ON DELETE CASCADE
) ENGINE=INNODB;

INSERT INTO block(project_id,name,random,textfirst) VALUES(1,'mainblock',1,1);

