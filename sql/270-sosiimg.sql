DROP TABLE IF EXISTS sosiimg;

CREATE TABLE sosiimg (
  sosiimg_id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  image_id INTEGER NOT NULL,
  scene_id INTEGER NOT NULL,
  position INTEGER NOT NULL,
  FOREIGN KEY (scene_id) REFERENCES scene(scene_id) ON DELETE CASCADE,
  FOREIGN KEY (image_id) REFERENCES image(image_id) ON DELETE CASCADE
) ENGINE=INNODB;


