CREATE DATABASE techsphere_database;
USE techsphere_database;

### WE NOW UPLOAD THE CSV"S DRECTLY AND CREATE FILES
### EMPLOYEE DETAILS COLUMN NOW

### WE SELECT ALL COLUMNS IN THIS CASE
select * from employee_details; 
select * from training_programs;

SET SQL_SAFE_UPDATES = 0;## TO ALLOW NON SAFE UPDATES

### WE NOW DO FIRST QUESTION PART 3
UPDATE training_programs tp JOIN employee_details ed  ON tp.employeename = ed.employee_name  AND tp.department_id = ed.department_id
SET tp.employeeid = ed.employee_id;

##CHECK RESULT
select * from training_programs;



### ANALYSIS TASKS
select * from employee_details; 
SELECT 
    e.employee_id,
    e.employee_name,
    e.department_id,
    e.performance_score,
    a.total_hours,
    a.days_present,
    a.late_check_ins
FROM employee_details e
JOIN attendance_records a ON e.employee_id = a.employeeid
ORDER BY e.performance_score DESC, a.total_hours DESC
LIMIT 10;
#####
#1. Employee Productivity Analysis
# Highest total hours & lowest absenteeism:
SELECT 
    e.employee_id,
    e.employee_name,
    a.total_hours,
    a.days_absent,
    a.days_present,
    a.overtime_hours
FROM employee_details e
JOIN attendance_records a ON e.employee_id = a.employeeid
ORDER BY a.total_hours DESC, a.days_absent ASC
LIMIT 10;


####
 #Departmental Training Impact
###Link training feedback to performance by department:
SELECT 
    e.department_id,
    ROUND(AVG(tp.feedback_score), 2) AS avg_training_feedback,
    ROUND(AVG(e.performance_score), 2) AS avg_performance_score,
    COUNT(tp.program_name) AS total_trainings
FROM training_programs tp
JOIN employee_details e ON tp.employeeid = e.employee_id
GROUP BY e.department_id
ORDER BY avg_training_feedback DESC;
####
#Project Budget Efficiency
# Budget per hour worked (per project):

SELECT 
    p.project_id,
    p.project_name,
    p.budget,
    COUNT(DISTINCT p.employeeid) AS team_size,
    SUM(a.total_hours) AS total_hours_worked,
    ROUND(p.budget/ NULLIF(SUM(a.total_hours), 0), 2) AS cost_per_hour
FROM projects_assignments p
JOIN attendance_records a ON p.employeeid = a.employeeid
GROUP BY p.project_id, p.project_name, p.budget
ORDER BY cost_per_hour ASC;

####
# Attendance Consistency
#Departments with max variance in days_present:

SELECT 
    e.department_id,
    ROUND(AVG(a.days_present), 2) AS avg_days_present,
    ROUND(STDDEV(a.days_present), 2) AS stddev_days_present
FROM employee_details e
JOIN attendance_records a ON e.employee_id = a.employeeid
GROUP BY e.department_id
ORDER BY stddev_days_present DESC;

####

#Training & Project Success Correlation
#Technologies learned vs technologies used in projects:

SELECT 
    tp.technologies_covered,
    p.technologies_used,
    COUNT(DISTINCT tp.employeeid) AS trained_employees,
    COUNT(DISTINCT p.project_id) AS projects_using_tech
FROM training_programs tp
JOIN projects_assignments p ON tp.employeeid = p.employeeid
WHERE p.technologies_used LIKE CONCAT('%', tp.technologies_covered, '%')
GROUP BY tp.technologies_covered, p.technologies_used
ORDER BY trained_employees DESC;

######
#  High-Impact Employees
# Excellent performers in high-budget projects:

SELECT 
    e.employee_id,
    e.employee_name,
    e.performance_score,
    p.project_name,
    p.budget
FROM employee_details e
JOIN projects_assignments p ON e.employee_id = p.employeeid
WHERE e.performance_score = 'Excellent'
  AND p.budget > (
    SELECT AVG(budget) FROM projects_assignments
)
ORDER BY p.budget DESC;


#####
#Cross Analysis: Training & Project Use of Tech
#Who trained & worked on projects using the same tech:
SELECT 
    e.employee_id,
    e.employee_name,
    tp.technologies_covered,
    p.project_name,
    p.technologies_used
FROM training_programs tp
JOIN projects_assignments p ON tp.employeeid = p.employeeid
JOIN employee_details e ON e.employee_id = tp.employeeid
WHERE p.technologies_used LIKE CONCAT('%', tp.technologies_covered, '%');


###