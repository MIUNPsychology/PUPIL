CREATE TABLE project (
  project_id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  teacher_id INTEGER NOT NULL,
  name VARCHAR(80) UNIQUE,
  description VARCHAR(80),
  displaywelcome BOOLEAN DEFAULT 0,
  displaythanks BOOLEAN DEFAULT 0,
  welcometop VARCHAR(200) DEFAULT "",
  welcomemid VARCHAR(200) DEFAULT "",
  welcomebottom VARCHAR(200) DEFAULT "",
  thankstop VARCHAR(200) DEFAULT "",
  thanksmid VARCHAR(200) DEFAULT "",
  thanksbottom VARCHAR(200) DEFAULT "",
  urlredirect VARCHAR(500) DEFAULT "",
  maxwidth INTEGER DEFAULT 0,
  maxheight INTEGER DEFAULT 0,
  flashright BOOLEAN DEFAULT 0,
  flashwrong BOOLEAN DEFAULT 0,
  flashwhite BOOLEAN DEFAULT 0,
  whitemin INTEGER DEFAULT 800,
  whitemax INTEGER DEFAULT 1600,
  hideopts BOOLEAN DEFAULT 0,
  displaypolicy INTEGER DEFAULT 1,
  splicearray BOOLEAN DEFAULT 0,
  subsetsize INTEGER DEFAULT 0,
  pauseimage_id INTEGER DEFAULT NULL,
  wrongimage_id INTEGER DEFAULT NULL,
  rightimage_id INTEGER DEFAULT NULL,
  blockrandom BOOLEAN DEFAULT 0,
  FOREIGN KEY (teacher_id) REFERENCES teacher(teacher_id) ON DELETE CASCADE
) ENGINE=INNODB;

INSERT INTO project(teacher_id,name,description) VALUES(1,'test','test project');
INSERT INTO project(teacher_id,name,description,displaywelcome,displaythanks,maxwidth,maxheight) VALUES(1,'visual1','my visual search project',1,1,600,500);

UPDATE project SET welcometop = 'Use numeric keys to select the image which does not fit' WHERE name = 'visual1';
UPDATE project SET welcomemid = '1 = top left, 2 = top right, 3 = bottom left, 4 = bottom right' WHERE name = 'visual1';
UPDATE project SET welcomebottom = 'Press any key to start experiment' WHERE name = 'visual1';

UPDATE project SET thankstop = 'Your data has now successfully been stored. Thank you for your participation' WHERE name = 'visual1';
UPDATE project SET thanksbottom = 'Press any key to be redirected to our homepage' WHERE name = 'visual1';
UPDATE project SET thanksmid = 'No cute furry little animals were hurt in any way by this experiment' WHERE name = 'visual1';

UPDATE project SET urlredirect = 'http://gathering.itm.miun.se/pupil' WHERE name = 'visual1';

