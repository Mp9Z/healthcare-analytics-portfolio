-- Q1: Female patients in Massachusetts... or your most common state
SELECT id, birthdate, gender, city, state
FROM patients
WHERE gender = 'F' AND state = 'Massachusetts'
ORDER BY birthdate;

-- Q2: Encounters with patient and payer details
SELECT e.id, e.start, e.encounterclass, e.total_claim_cost,
       p.gender, p.state, py.name AS payer_name
FROM encounters e
JOIN patients p  ON p.id = e.patient
JOIN payers  py  ON py.id = e.payer
LIMIT 100;

-- Q3: LEFT JOIN: patients with NO encounters
SELECT p.id
FROM patients p
LEFT JOIN encounters e ON e.patient = p.id
WHERE e.id IS NULL;

-- Q4: Volume and average cost by encounter class
SELECT encounterclass,
       COUNT(*) AS encounters,
       ROUND(AVG(total_claim_cost)::numeric, 2) AS avg_cost,
       ROUND(SUM(total_claim_cost)::numeric, 2) AS total_cost
FROM encounters
GROUP BY encounterclass
ORDER BY total_cost DESC;

-- Q5: Payers with total claim cost above 1M (HAVING vs WHERE)
SELECT py.name, SUM(e.total_claim_cost) AS total_cost
FROM encounters e
JOIN payers py ON py.id = e.payer
GROUP BY py.name
HAVING SUM(e.total_claim_cost) > 1000000
ORDER BY total_cost DESC;

-- Q6: Age bands
SELECT CASE
         WHEN age < 18 THEN '0-17'
         WHEN age < 40 THEN '18-39'
         WHEN age < 65 THEN '40-64'
         ELSE '65+'
       END AS age_band,
       COUNT(*) AS patients
FROM (
  SELECT id, DATE_PART('year', AGE(COALESCE(deathdate, CURRENT_DATE), birthdate)) AS age
  FROM patients
) t
GROUP BY 1
ORDER BY 1;

-- Q7: Coverage ratio by payer
SELECT py.name,
       ROUND((SUM(e.payer_coverage) / NULLIF(SUM(e.total_claim_cost), 0) * 100)::numeric, 1) AS pct_covered
FROM encounters e
JOIN payers py ON py.id = e.payer
GROUP BY py.name
ORDER BY pct_covered DESC;

-- Q8: Patients whose lifetime claim cost is above the average patient
SELECT patient, SUM(total_claim_cost) AS total_cost
FROM encounters
GROUP BY patient
HAVING SUM(total_claim_cost) > (
    SELECT AVG(patient_total)
    FROM (SELECT SUM(total_claim_cost) AS patient_total
          FROM encounters GROUP BY patient) x
)
ORDER BY total_cost DESC;

-- Q9: Patients with a diabetes diagnosis (IN subquery)
SELECT id, gender, state
FROM patients
WHERE id IN (SELECT patient FROM conditions WHERE description ILIKE '%diabetes%');

-- Q10: Monthly encounter trend
SELECT DATE_TRUNC('month', start) AS month, COUNT(*) AS encounters
FROM encounters
GROUP BY 1
ORDER BY 1;

-- Q11: Duplicate check
SELECT id, COUNT(*) FROM encounters GROUP BY id HAVING COUNT(*) > 1;

-- Q12: Null profile on key columns
SELECT COUNT(*) AS total_rows,
       COUNT(*) - COUNT(payer) AS null_payer,
       COUNT(*) - COUNT(total_claim_cost) AS null_cost,
       SUM(CASE WHEN total_claim_cost < 0 THEN 1 ELSE 0 END) AS negative_cost
FROM encounters;

