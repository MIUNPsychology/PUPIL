CREATE TABLE image (
  image_id INTEGER PRIMARY KEY NOT NULL AUTO_INCREMENT,
  category_id INTEGER NOT NULL,
  file_name VARCHAR(80),
  FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE CASCADE
) ENGINE=INNODB;

ALTER TABLE project ADD FOREIGN KEY (pauseimage_id) REFERENCES image(image_id) ON DELETE SET NULL;
ALTER TABLE project ADD FOREIGN KEY (wrongimage_id) REFERENCES image(image_id) ON DELETE SET NULL;
ALTER TABLE project ADD FOREIGN KEY (rightimage_id) REFERENCES image(image_id) ON DELETE SET NULL;

INSERT INTO image(category_id,file_name) VALUES(1,"neutral1.jpg");
INSERT INTO image(category_id,file_name) VALUES(1,"neutral2.jpg");
INSERT INTO image(category_id,file_name) VALUES(1,"neutral3.jpg");
INSERT INTO image(category_id,file_name) VALUES(1,"neutral4.jpg");
INSERT INTO image(category_id,file_name) VALUES(2,"farlig1.jpg");
INSERT INTO image(category_id,file_name) VALUES(2,"farlig2.jpg");
INSERT INTO image(category_id,file_name) VALUES(2,"farlig3.jpg");
INSERT INTO image(category_id,file_name) VALUES(2,"farlig4.jpg");

