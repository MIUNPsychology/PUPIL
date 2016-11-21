DROP TABLE IF EXISTS reaction;

CREATE TABLE reaction (nr INTEGER PRIMARY KEY NOT NULL, namn VARCHAR(80)) ENGINE InnoDB;

INSERT INTO reaction(nr,namn) VALUES(1,"Joel");
INSERT INTO reaction(nr,namn) VALUES(2,"Jan");
INSERT INTO reaction(nr,namn) VALUES(3,"Jens");


