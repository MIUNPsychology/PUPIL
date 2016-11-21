DROP VIEW IF EXISTS filenames;

CREATE VIEW filenames
AS SELECT 
  image.image_id, 
  category.category_id,
  category.name as category,
  image.file_name as image,
  category.project_id
FROM
  category, image
WHERE
  category.category_id = image.category_id;

