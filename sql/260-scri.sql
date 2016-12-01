DROP TABLE IF EXISTS scri;

CREATE TABLE scri (
  scri_id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  scene_id INTEGER NOT NULL,
  category_id INTEGER NOT NULL,
  position INTEGER NOT NULL,
  keychar CHAR NOT NULL,
  FOREIGN KEY (scene_id) REFERENCES scene(scene_id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE CASCADE
) ENGINE=INNODB;

INSERT INTO scri(scene_id,category_id,position,keychar) VALUES(1,1,1,1);
INSERT INTO scri(scene_id,category_id,position,keychar) VALUES(1,1,2,2);
INSERT INTO scri(scene_id,category_id,position,keychar) VALUES(1,1,3,3);
INSERT INTO scri(scene_id,category_id,position,keychar) VALUES(1,2,4,4);

INSERT INTO scri(scene_id,category_id,position,keychar) VALUES(2,2,1,1);
INSERT INTO scri(scene_id,category_id,position,keychar) VALUES(2,1,2,2);
INSERT INTO scri(scene_id,category_id,position,keychar) VALUES(2,1,3,3);
INSERT INTO scri(scene_id,category_id,position,keychar) VALUES(2,1,4,4);


