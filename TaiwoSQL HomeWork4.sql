
--Taiwo Adeyemi


--QUESTION 1

ALTER TABLE MAG.WORKER
ALTER COLUMN Work_Num INT NOT NULL;

ALTER TABLE MAG.WORKER
ADD CONSTRAINT PK_WORKER PRIMARY KEY (Work_Num);

--QUESTION 2
ALTER TABLE MAG.EQUIPMENT
ALTER COLUMN Equip_Num INT NOT NULL;

ALTER TABLE MAG.EQUIPMENT
ADD CONSTRAINT PK_EQUIPMENT PRIMARY KEY (Equip_Num);

--QUESTION 3
CREATE TABLE MAG.REPAIR (
  Rep_Num INTEGER PRIMARY KEY,
  Equip_Num INTEGER,
  Rep_Date DATE,
  CONSTRAINT FK_REPAIR_EQUIPMENT FOREIGN KEY (Equip_Num) REFERENCES MAG.EQUIPMENT(EQUIP_NUM),
  CONSTRAINT CHK_REPAIR_Equip_Num CHECK (Equip_Num >= 0 AND Equip_Num <= 9999999999),
  CONSTRAINT CHK_REPAIR_Rep_Date CHECK (Rep_Date IS NOT NULL)
);

-- QUESTION 4
CREATE TABLE MAG.PERFORMS (
  Work_Num INT,
  Rep_Num INT,
  PRIMARY KEY (Work_Num, Rep_Num),
  CONSTRAINT FK_PERFORMS_WORKER FOREIGN KEY (Work_Num) REFERENCES MAG.WORKER(Work_Num),
  CONSTRAINT FK_PERFORMS_REPAIR FOREIGN KEY (Rep_Num) REFERENCES MAG.REPAIR(Rep_Num),
  CONSTRAINT CHK_PERFORMS_Work_Num CHECK (Work_Num >= 0 AND Work_Num <= 9999999),
  CONSTRAINT CHK_PERFORMS_Rep_Num CHECK (Rep_Num >= 0)
);


--QUESTION 5
INSERT INTO MAG.REPAIR (Rep_Num, Equip_Num, Rep_Date)
VALUES (100, 20038459, 'May 11, 2023');

INSERT INTO MAG.REPAIR (Rep_Num, Equip_Num, Rep_Date)
VALUES (101, 25900414, 'May 12, 2023');

-- QUESTION 6
INSERT INTO MAG.PERFORMS (Work_Num, Rep_Num)
VALUES (4933, 100);

INSERT INTO MAG.PERFORMS (Work_Num, Rep_Num)
VALUES (31009, 100);

INSERT INTO MAG.PERFORMS (Work_Num, Rep_Num)
VALUES (4933, 101);

-- QUESTION 7
UPDATE MAG.WORKER
SET Work_FName = 'Steven'
WHERE Work_Num = 30343;

-- QUESTION 8
UPDATE MAG.PART
SET Part_QOH = Part_QOH + 100
WHERE Part_Descript LIKE '%bracket%';

-- QUESTION 9
UPDATE MAG.SCHEDULE
SET sch_actual_qty = 500
WHERE sch_num = 6674;

-- QUESTION 10
DELETE FROM MAG.SCHEDULE
WHERE sch_num = 6833;

-- QUESTION 11 (Once spUpsertSchedule procedure is created...and you want to excute it next time again. You have to drop it then again excute it to create)

CREATE PROCEDURE MAG.spUpsertSchedule
  @part_num INT,
  @need_date DATE,
  @quantity INT
AS
BEGIN
  -- Check if the part exists in the PART table
  DECLARE @valid_part INT;
  SELECT @valid_part = COUNT(*) FROM MAG.PART WHERE part_num = @part_num;

  IF @valid_part = 0
  BEGIN
    PRINT 'The part cannot be found.';
    RETURN;
  END;

  -- Check if there is an existing entry for the part on the specified date
  DECLARE @existing_quantity INT;
  SET @existing_quantity = NULL;

  SELECT @existing_quantity = sch_plan_qty
  FROM MAG.SCHEDULE
  WHERE part_num = @part_num AND sch_need_date = @need_date;

  IF @existing_quantity IS NOT NULL
  BEGIN
    -- Update the existing entry with the new quantity
    UPDATE MAG.SCHEDULE
    SET sch_plan_qty = @existing_quantity + @quantity
    WHERE part_num = @part_num AND sch_need_date = @need_date;

    DECLARE @quantity_updated_msg NVARCHAR(100);
    DECLARE @part_num_str NVARCHAR(10);
    DECLARE @need_date_str NVARCHAR(10);
    DECLARE @new_quantity_str NVARCHAR(10);

    SET @part_num_str = @part_num;
    SET @need_date_str = @need_date;
    SET @new_quantity_str = @existing_quantity + @quantity;

    SET @quantity_updated_msg = 'Quantity updated to ' + @new_quantity_str
                               + ' for Part ' + @part_num_str
                               + ' needed on ' + @need_date_str + '.';

    PRINT @quantity_updated_msg;
  END
  ELSE
  BEGIN
    -- Insert a new row in the SCHEDULE table
    DECLARE @new_schedule_num INT;
    SET @new_schedule_num = NULL;

    SELECT @new_schedule_num = MAX(sch_num) + 1 FROM MAG.SCHEDULE;

    INSERT INTO MAG.SCHEDULE (sch_num, sch_create_date, sch_need_date, sch_plan_qty, sch_actual_qty, part_num)
    VALUES (@new_schedule_num, GETDATE(), @need_date, @quantity, NULL, @part_num);

    PRINT 'New entry added to the schedule.';
  END;
END;



