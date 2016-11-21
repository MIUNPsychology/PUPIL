DROP VIEW IF EXISTS blinkfilenames;

CREATE VIEW
  blinkfilenames
AS SELECT
  projecta.project_id,
  filenamesa.category as wrongcategory,
  filenamesa.image as wrongimage,
  filenamesb.category as rightcategory,
  filenamesb.image as rightimage,
  filenamesc.category as pausecategory,
  filenamesc.image as pauseimage
FROM
  project AS projecta LEFT JOIN filenames AS filenamesa ON projecta.rightimage_id = filenamesa.image_id,
  project AS projectb LEFT JOIN filenames AS filenamesb ON projectb.wrongimage_id = filenamesb.image_id,
  project AS projectc LEFT JOIN filenames AS filenamesc ON projectc.pauseimage_id = filenamesc.image_id
WHERE
  projecta.project_id = projectb.project_id AND
  projectb.project_id = projectc.project_id;




