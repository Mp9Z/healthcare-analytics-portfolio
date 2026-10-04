--Q4
SELECT encounterclass,
        Count(*) AS encounter,
        Round(AVG(total_claim_cost)::numeric, 2) AS AVG_Cost,
        Round(SUM(total_claim_cost)::numeric, 2) AS total_cost
FROM encounters
GROUP BY encounterclass
ORDER BY total_cost DESC;


--Q5 payers with total claims bove 1m
SELECT Py.name, SUM(e.total_claim_cost) AS total_cost
FROM encounters e
JOIN payers py ON py.id = e.payer
GROUP BY py.name
HAVING SUM(e.total_claim_cost) > 1000000
ORDER BY total_cost DESC;


--Q6 age grouping

SELECT CASE
        WHEN age < 18 THEN '0-17'
        WHEN age < 40 THEN '18-39'
        WHEN age < 65 THEN '40-64'
        ELSE '65+'
    END AS age_band,
    COUNT (*) AS patients
FROM (
    SELECT ID, DATE_PART('year', AGE(COALESCE(deathdate, CURRENT_DATE), birthdate)) AS age
    FROM patients
) t
GROUP BY 1
ORDER BY 1;

--Q8 patient whose life time cost is > than the avg cost

SELECT patient,
SUM(total_claim_cost) AS total_cost
FROM encounters
GROUP BY patient
HAVING SUM(total_claim_cost) > (
    SELECT AVG(patient_total)
    FROM (SELECT SUM(total_claim_cost) AS patient_total
         FROM encounters GROUP BY patient) x
)
ORDER BY total_cost DESC;

--Q1 how mant distinct patients have each

SELECT description,
        COUNT(DISTINCT patient) AS patients,
        COUNT(*) AS diagnosis_records
FROM conditions
GROUP BY description
ORDER BY patients DESC
LIMIT 5;

--Q2 avg encounters for patient

SELECT ROUND (AVG(encounter_count)::numeric, 2) AS avg_encounters_per_patient
FROM (
    SELECT patient, COUNT(*) AS encounter_count
    FROM encounters
    GROUP BY patient
) t;

--B FOR 0 ENCOUNTER PATIENTS
 SELECT ROUNd(AVG(encounter_count))::numeric, 2) AS avg_encounters_per_patient
 FROM (
    SELECT p.id, COUNT(e.id) AS encounter_count
    FROM patients p
    LEFT JOIN encounters e ON e.patient = p.id
    GROUP BY p.id
 ) t;

--Q3 organizations by avg  claim cost

SELECT o.name,
        COUNT(*) AS encounters,
        ROUND(AVG(e.total_claim_cost)::numeric, 2) AS avg_cost
FROM encounters e
JOIN organizations o ON o.id = e.organization
GROUP BY o.name
HAVING COUNT(*) >= 20
ORDER BY avg_cost DESC
LIMIT 10;

