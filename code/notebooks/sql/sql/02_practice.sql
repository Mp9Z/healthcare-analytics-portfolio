--Q4
SELECT encounterclass,
        Count(*) AS encounter,
        Round(AVG(total_claim_cost)::numeric, 2) AS AVG_Cost,
        Round(SUM(total_claim_cost)::numeric, 2) AS total_cost
FROM encounters
GROUP BY encounterclass
ORDER BY total_cost DESC;


--Q5 payers with total claims bove 1m
SELECT Py.name, 
SUM(e.total_claim_cost) AS total_cost
FROM encounters e
JOIN payers py ON py.id = e.payers
GROUP BY py.name
HAVING SUM(e.total_claim_cost) > 1000000
ORDER BY total_cost DESC;


--Q6 age grouping

SELECT CASE
        WHEN age < 18 THEN '0-17',
        WHEN age < 40 THEN '18-39',
        WHEN age < 65 THEN '40-64',
        ELSE '65+'
    END AS age_band,
    COUNT (*) AS patients
FROM (
    SELECT ID, DATE_PART('year', AGE(COALESEC(deathdate, CURRENT_DATE), birthdate)) AS age
    FROM patients
) t
GROUP BY 1
ORDER BY 1;

--Q8 patient whose life time cost is > than the avg cost

SELECT patient,
SUM(total_claim_cost) AS total_cost
FROM encounters
GROUP BY patient
HAVING SUM(total_claim_cost) > AVG(
    SELECT AVG (patient_cost)
    FROM (SELECT SUM(total_claim_cost) AS patient_total
         FROM encounters GROUP BY patient) x
)
ORDER BY total_cost DESC;