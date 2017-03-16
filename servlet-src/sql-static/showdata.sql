select 
  project.name as project, 
  scene.description as scene, 
  student.login as student, 
  input.testcase_id as testcase, 
  input.time_start, 
  input.time_end, 
  input.time_delta, 
  input.actual_input, 
  input.correct_input 
from 
  input, scene, project, student, testcase 
where 
  input.scene_id = scene.scene_id and 
  scene.project_id = project.project_id and 
  input.testcase_id = testcase.testcase_id and 
  student.student_id = testcase.student_id and
  project.name = ?;


