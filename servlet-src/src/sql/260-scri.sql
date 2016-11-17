CREATE TABLE scri (
  scri_id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  scene_id INTEGER NOT NULL,
  category_id INTEGER NOT NULL,
  position INTEGER NOT NULL,
  keychar CHAR NOT NULL,
  FOREIGN KEY (scene_id) REFERENCES scene(scene_id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE CASCADE
) ENGINE=INNODB;
