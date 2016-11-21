DROP TABLE IF EXISTS input;

CREATE TABLE input (
  input_id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  testcase_id INTEGER NOT NULL,
  scene_id INTEGER NOT NULL,
  time_start BIGINT DEFAULT 0,
  time_end BIGINT DEFAULT 0,
  time_delta INTEGER,
  actual_input VARCHAR(5),
  correct_input BOOLEAN,
  FOREIGN KEY (testcase_id) REFERENCES testcase(testcase_id) ON DELETE CASCADE,
  FOREIGN KEY (scene_id) REFERENCES scene(scene_id) ON DELETE CASCADE
) ENGINE=INNODB;

