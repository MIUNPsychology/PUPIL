DROP TABLE IF EXISTS scriscene;

CREATE TABLE scriscene (
  scriscene_id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  scene_id INTEGER NOT NULL,
  noduplicates BOOLEAN,
  FOREIGN KEY (scene_id) REFERENCES scene(scene_id) ON DELETE CASCADE
) ENGINE=INNODB;

INSERT INTO scriscene(scene_id,noduplicates) VALUES(1,1);
INSERT INTO scriscene(scene_id,noduplicates) VALUES(2,1);

