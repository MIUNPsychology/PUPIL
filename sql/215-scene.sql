DROP TABLE IF EXISTS scene;

CREATE TABLE scene (
  scene_id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  scenetype_id INTEGER NOT NULL,
  pattern_id INTEGER NOT NULL,
  project_id INTEGER NOT NULL,
  timeout INTEGER DEFAULT 0 NOT NULL,
  description VARCHAR(80),
  lead VARCHAR(250) DEFAULT '',
  correctkey CHAR DEFAULT '~',
  UNIQUE(project_id,description),
  FOREIGN KEY (scenetype_id) REFERENCES scenetype(scenetype_id) ON DELETE CASCADE,
  FOREIGN KEY (pattern_id) REFERENCES pattern(pattern_id) ON DELETE CASCADE,
  FOREIGN KEY (project_id) REFERENCES project(project_id) ON DELETE CASCADE
) ENGINE=INNODB;


INSERT INTO scene(scenetype_id,pattern_id,project_id,timeout,description,lead,correctkey) VALUES(2,7,1,0,'scene01','',4);
INSERT INTO scene(scenetype_id,pattern_id,project_id,timeout,description,lead,correctkey) VALUES(2,7,1,0,'scene02','',1);


