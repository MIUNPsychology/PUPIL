CREATE TABLE sceneblock (
  block_id INTEGER NOT NULL,
  scene_id INTEGER NOT NULL,
  FOREIGN KEY (block_id) REFERENCES block(block_id) ON DELETE CASCADE,
  FOREIGN KEY (scene_id) REFERENCES scene(scene_id) ON DELETE CASCADE
) ENGINE=INNODB;
