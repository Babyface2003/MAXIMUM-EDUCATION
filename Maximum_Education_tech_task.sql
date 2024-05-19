DROP TABLE IF EXISTS Managers CASCADE;
DROP TABLE IF EXISTS Agreements CASCADE;
DROP TABLE IF EXISTS Payments CASCADE;

CREATE TABLE Managers (
    id_Manager UUID PRIMARY KEY,
    BE_lvl1 TEXT,
    BE_lvl2 TEXT,
    BE_lvl3 TEXT
);

CREATE TABLE Agreements (
    id_Agreement UUID PRIMARY KEY,
    Amount FLOAT,
    id_Manager UUID,
    id_Student UUID,
    Season_sale TEXT,
    Season_training TEXT,
    Segment TEXT,
    FOREIGN KEY (id_Manager) REFERENCES Managers(id_Manager)
);

CREATE TABLE Payments (
    id_Payment UUID PRIMARY KEY,
    id_Agreement UUID,
    Payment_number VARCHAR(10),
    Scheduled_payment_date TIMESTAMP(0),
    Actual_payment_date TIMESTAMP(0),
    Scheduled_payment_amount NUMERIC,
    Actual_payment_amount INT,
    FOREIGN KEY (id_Agreement) REFERENCES Agreements(id_Agreement)
);

DELETE FROM Agreements a
WHERE a.id_Manager NOT IN (SELECT id_Manager FROM Managers);

DELETE FROM Managers m
WHERE m.id_Manager NOT IN (SELECT id_Manager FROM Managers);

COPY Managers
FROM 'D:\CSV_TECH_TASK\MAXIMUM EDUCATION\Managers.csv'
DELIMITER ';'
CSV 
HEADER;

COPY Agreements
FROM 'D:\CSV_TECH_TASK\MAXIMUM EDUCATION\Agreements.csv'
DELIMITER ';'
CSV 
HEADER;

COPY Payments
FROM 'D:\CSV_TECH_TASK\MAXIMUM EDUCATION\Payments.csv'
DELIMITER ';'
CSV 
HEADER;
--№1
SELECT  a.Season_sale, 
		COUNT(DISTINCT a.id_Agreement) AS Agreements,
		COUNT(DISTINCT a.id_Student) AS Student,
        SUM(a.Amount) AS Amount, 
		COUNT(DISTINCT a.id_Agreement) * 1.0 / COUNT(DISTINCT a.id_Student) AS Agreements_Counterparties,
        SUM(a.Amount) * 1.0 / COUNT(DISTINCT a.id_Agreement) AS Average_check
from Agreements a
inner join Payments p on a.id_Agreement = p.id_Agreement
where Payment_number = '1' and Actual_payment_date is not null and Season_sale < Season_training
group by a.Season_sale
order by Amount DESC;

--№2
SELECT  a.id_Student, 
		 CAST(SUBSTRING(a.Season_training, 1, 4) AS INT) + 
        CASE 
            WHEN a.Segment LIKE '%11%' THEN 0
            WHEN a.Segment LIKE '%10%' THEN 1
            WHEN a.Segment LIKE '%9%' THEN 2
            WHEN a.Segment LIKE '%8%' THEN 3
            WHEN a.Segment LIKE '%7%' THEN 4
            WHEN a.Segment LIKE '%6%' THEN 5
            WHEN a.Segment LIKE '%5%' THEN 6
            ELSE NULL
        END AS Graduation_Year,
		COUNT(DISTINCT a.id_Agreement) AS Agreements_count
FROM Agreements a
INNER JOIN Payments p ON a.id_Agreement = p.id_Agreement
WHERE Payment_number = '1' AND Actual_payment_date IS NOT null AND Season_sale < Season_training
GROUP BY a.id_Student,
CAST(SUBSTRING(a.Season_training, 1, 4) AS INT) + 
        CASE 
            WHEN a.Segment LIKE '%11%' THEN 0
            WHEN a.Segment LIKE '%10%' THEN 1
            WHEN a.Segment LIKE '%9%' THEN 2
            WHEN a.Segment LIKE '%8%' THEN 3
            WHEN a.Segment LIKE '%7%' THEN 4
            WHEN a.Segment LIKE '%6%' THEN 5
            WHEN a.Segment LIKE '%5%' THEN 6
            ELSE NULL
        END
ORDER BY Agreements_count;

--3
SELECT CASE
			WHEN m.BE_lvl1 = 'Старшая школа' THEN 'ОП Старшая школа'
			WHEN m.BE_lvl1 = 'Средняя школа' OR  m.BE_lvl1 = 'Екатеринбург+НН+НСК' THEN 'ОП Средняя школа'
			ELSE m.BE_lvl1
		END AS BE_lvl1,
		COUNT(p.id_Payment) AS Late_payments,
		 COUNT(DISTINCT 
			   CASE WHEN p.Actual_payment_date > p.Scheduled_payment_date THEN m.id_Manager
			   ELSE NULL 
			   END) AS Late_managers,
		COUNT(DISTINCT m.id_Manager) AS Managers,
		ROUND(
        (COUNT(DISTINCT CASE WHEN p.Actual_payment_date > p.Scheduled_payment_date THEN m.id_Manager ELSE NULL END) * 1.0 
        / COUNT(DISTINCT m.id_Manager)) * 100, 2
    	) AS Late_managers_procent
FROM Managers m
INNER JOIN Agreements a ON a.id_Manager = m.id_Manager
INNER JOIN Payments p ON p.id_Agreement = a.id_Agreement
WHERE Actual_payment_date IS NOT NULL AND Season_sale < Season_training AND NOT Actual_payment_amount < 0
GROUP BY CASE
			WHEN m.BE_lvl1 = 'Старшая школа' THEN 'ОП Старшая школа'
			WHEN m.BE_lvl1 = 'Средняя школа' OR  m.BE_lvl1 = 'Екатеринбург+НН+НСК' THEN 'ОП Средняя школа'
			ELSE m.BE_lvl1
		END
ORDER BY Late_payments;



