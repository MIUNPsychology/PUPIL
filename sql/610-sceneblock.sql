DROP TABLE IF EXISTS sceneblock;

CREATE TABLE sceneblock (
  block_id INTEGER NOT NULL,
  scene_id INTEGER NOT NULL,
  FOREIGN KEY (block_id) REFERENCES block(block_id) ON DELETE CASCADE,
  FOREIGN KEY (scene_id) REFERENCES scene(scene_id) ON DELETE CASCADE
) ENGINE=INNODB;

INSERT INTO sceneblock(block_id,scene_id) VALUES(1,1);
INSERT INTO sceneblock(block_id,scene_id) VALUES(1,2);

