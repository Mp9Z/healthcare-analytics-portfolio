\echo '--- Q1: female patients in Massachusetts'
SELECT id, birthdate, gender, city, state
FROM patients
WHERE gender = 'F' AND state = 'Massachusetts'
ORDER BY birthdate
LIMIT 10;

\echo '--- Q2: encounters joined to patients and payers'
SELECT e.id, e.start, e.encounterclass, e.total_claim_cost,
       p.gender, p.state, py.name AS payer_name
FROM encounters e
JOIN patients p ON p.id = e.patient
JOIN payers py ON py.id = e.payer
LIMIT 10;

\echo '--- Q3: patients with NO encounters (LEFT JOIN)'
SELECT p.id
FROM patients p
LEFT JOIN encounters e ON e.patient = p.id
WHERE e.id IS NULL
LIMIT 10;

\echo '--- Q4: volume and cost by encounter class'
SELECT encounterclass,
       COUNT(*) AS encounters,
       ROUND(AVG(total_claim_cost)::numeric, 2) AS avg_cost,
       ROUND(SUM(total_claim_cost)::numeric, 2) AS total_cost
FROM encounters
GROUP BY encounterclass
ORDER BY total_cost DESC;

\echo '--- Q5: payers with total cost above 100000 (HAVING)'
SELECT py.name, ROUND(SUM(e.total_claim_cost)::numeric, 2) AS total_cost
FROM encounters e
JOIN payers py ON py.id = e.payer
GROUP BY py.name
HAVING SUM(e.total_claim_cost) > 100000
ORDER BY total_cost DESC;

\echo '--- Q6: patients by age band (CASE)'
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

\echo '--- Q7: percent of cost covered by each payer'
SELECT py.name,
       ROUND((SUM(e.payer_coverage) / NULLIF(SUM(e.total_claim_cost), 0) * 100)::numeric, 1) AS pct_covered
FROM encounters e
JOIN payers py ON py.id = e.payer
GROUP BY py.name
ORDER BY pct_covered DESC;

\echo '--- Q8: patients above average lifetime cost (subquery)'
SELECT patient, ROUND(SUM(total_claim_cost)::numeric, 2) AS total_cost
FROM encounters
GROUP BY patient
HAVING SUM(total_claim_cost) > (
    SELECT AVG(patient_total)
    FROM (SELECT SUM(total_claim_cost) AS patient_total
          FROM encounters GROUP BY patient) x
)
ORDER BY total_cost DESC
LIMIT 10;

\echo '--- Q9: patients with a diabetes diagnosis (IN subquery)'
SELECT id, gender, state
FROM patients
WHERE id IN (SELECT patient FROM conditions WHERE description ILIKE '%diabetes%')
LIMIT 10;

\echo '--- Q10: monthly encounter trend'
SELECT DATE_TRUNC('month', start) AS month, COUNT(*) AS encounters
FROM encounters
GROUP BY 1
ORDER BY 1 DESC
LIMIT 24;

\echo '--- Q11: duplicate encounter ids (expect 0 rows)'
SELECT id, COUNT(*) FROM encounters GROUP BY id HAVING COUNT(*) > 1;

\echo '--- Q12: null and negative profile'
SELECT COUNT(*) AS total_rows,
       COUNT(*) - COUNT(payer) AS null_payer,
       COUNT(*) - COUNT(total_claim_cost) AS null_cost,
       SUM(CASE WHEN total_claim_cost < 0 THEN 1 ELSE 0 END) AS negative_cost
FROM encounters;
