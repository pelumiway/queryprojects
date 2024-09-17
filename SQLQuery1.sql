-- Taiwo Adeyemi

-- QUESTION 0
--Create the MAG schema
CREATE SCHEMA MAG;
-- Copy the WORKER table
SELECT *
INTO MAG.WORKER
FROM STARTERDB.MAG.WORKER;
-- Copy the PART table
SELECT *
INTO MAG.PART
FROM STARTERDB.MAG.PART;
-- Copy the SCHEDULE table
SELECT *
INTO MAG.SCHEDULE
FROM STARTERDB.MAG.SCHEDULE;
-- Copy the EQUIPMENT table
SELECT *
INTO MAG.EQUIPMENT
FROM STARTERDB.MAG.EQUIPMENT;
-- Copy the JOB table
SELECT *
INTO MAG.JOB
FROM STARTERDB.MAG.JOB;
--QUESTION 1
SELECT 
  w.Work_LName AS WORK_LNAME,
  e.Equip_Num AS EQUIP_NUM,
  e.Equip_Type AS EQUIP_TYPE,
  FORMAT(j.Job_StartTime, 'MMMM dd, yyyy') AS JOB_STARTTIME,
  (w.Work_Wage * j.Job_Hours_Worked) + (e.Equip_Startup_Cost + (e.Equip_Hourly_Run_Cost * j.Job_Hours_Worked)) AS 'TOTAL COST',
  j.Job_Qty_Produced AS JOB_QTY_PRODUCED
FROM 
  MAG.WORKER w
  JOIN MAG.JOB j ON w.Work_Num = j.Work_Num
  JOIN MAG.EQUIPMENT e ON j.Equip_Num = e.Equip_Num
WHERE 
  ((w.Work_Wage * j.Job_Hours_Worked) + (e.Equip_Startup_Cost + (e.Equip_Hourly_Run_Cost * j.Job_Hours_Worked))) > 250
  AND j.Job_Qty_Produced < 300
ORDER BY 
  'total cost' DESC, job_qty_produced ASC;

 --QUESTION 2
  SELECT 
  w.Work_Num AS WORK_NUM,
  w.Work_LName AS WORK_LNAME,
  w.Work_FName AS WORK_FNAME
FROM 
  MAG.WORKER w
WHERE 
  (w.Work_Title LIKE 'Machinist%')
  AND w.Work_Num NOT IN (
    SELECT j.Work_Num
    FROM MAG.JOB j
    JOIN MAG.EQUIPMENT e ON j.Equip_Num = e.Equip_Num
    WHERE e.Equip_Type LIKE '%welder%'
  )
ORDER BY 
  WORK_LNAME ASC, WORK_FNAME ASC;

  --QUESTION 3
  SELECT 
  e.Equip_Num AS EQUIP_NUM,
  e.Equip_Type AS EQUIP_TYPE,
  CONCAT('$', CAST(e.Equip_Startup_Cost + (e.Equip_Hourly_Run_Cost * 1) AS DECIMAL(10,2))) AS '1 HOUR RUN',
  CONCAT('$', CAST(e.Equip_Startup_Cost + (e.Equip_Hourly_Run_Cost * 4) AS DECIMAL(10,2))) AS '4 HOUR RUN',
  CONCAT('$', CAST(e.Equip_Startup_Cost + (e.Equip_Hourly_Run_Cost * 8) AS DECIMAL(10,2))) AS '8 HOUR RUN'
FROM 
  MAG.EQUIPMENT e
WHERE 
  e.Equip_Type IN ('Hydraulic Press', 'Injector', 'Arc Welder')
ORDER BY 
  CAST(e.Equip_Startup_Cost + (e.Equip_Hourly_Run_Cost * 1) AS DECIMAL(10,2)) ASC;

  --QUESTION 4
  SELECT 
  CONCAT(w.Work_FName, ' ', w.Work_LName) AS Worker,
  p.Part_Num AS Part_Num,
  p.PART_DESCRIPT AS Part_Descript,
  CONCAT('$', FORMAT(AVG(w.Work_Wage * j.Job_Hours_Worked / j.Job_Qty_Produced), 'N2')) AS 'Avg Labor Cost Per Unit',
  COUNT(j.Job_Num) AS 'Times Produced'
FROM 
  MAG.WORKER w
  JOIN MAG.JOB j ON w.Work_Num = j.Work_Num
  JOIN MAG.PART p ON j.Part_Num = p.Part_Num
GROUP BY 
  CONCAT(w.Work_FName, ' ', w.Work_LName),
  p.PART_DESCRIPT,
  p.Part_Num
HAVING 
  COUNT(j.Job_Num) > 2
ORDER BY 
  'Avg Labor Cost Per Unit' ASC;


  --QUESTION 5
  SELECT
  w.Work_Num AS WORK_NUM,
  w.Work_FName AS WORK_FNAME,
  w.Work_LName AS WORK_LNAME
FROM
  MAG.WORKER w, MAG.JOB j, MAG.EQUIPMENT e
WHERE
  w.Work_Num = j.Work_Num
  AND j.Equip_Num = e.Equip_Num
  AND e.Equip_Type = 'Reamer'
  AND j.Job_Hours_Worked = (
    SELECT MAX(j2.Job_Hours_Worked)
    FROM MAG.JOB j2, MAG.EQUIPMENT e2
    WHERE j2.Equip_Num = e2.Equip_Num
    AND e2.Equip_Type = 'Reamer'
  );


