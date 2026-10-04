# healthcare-analytics-portfolio

# Day 1 Notes

## 3 things I learned
1. Setting up a full analytics environment (PostgreSQL, Python, Git/GitHub) and loading
   raw CSVs into a database with a repeatable Python script, with the password kept in an
   environment variable instead of the code.
2. The join type changes the answer: INNER JOIN drops unmatched rows, while LEFT JOIN keeps
   them. That's how I found patients with no encounters.
3. Aggregation needs the right level of detail. COUNT(DISTINCT patient) counts people,
   while COUNT(*) counts records, and AVG(COUNT(*)) isn't allowed, so I used a subquery.

## A query that surprised me, and why
EDIT: Pick one real moment. Example: "Stretch 1 surprised me because the top 'conditions'
included things like employment status and medication reviews, not just diseases. It showed
me that raw healthcare data needs filtering before it answers a business question."

## Interview questions
1. **INNER JOIN vs LEFT JOIN?**
   INNER JOIN returns only rows with a match in both tables. LEFT JOIN returns every row
   from the left table, with NULLs where the right table has no match. I use LEFT JOIN
   to find missing relationships (e.g., patients with no encounters) or to avoid
   accidentally dropping records from a report.

2. **WHERE vs HAVING?**
   WHERE filters individual rows before grouping. HAVING filters groups after aggregation,
   so it can use aggregates like SUM() or COUNT(). Example: WHERE state = 'Massachusetts'
   filters rows, while HAVING SUM(total_claim_cost) > 100000 filters payers.

3. **When would I use a subquery instead of a join?**
   Use a subquery when I need a computed value to compare against (e.g., patients above the
   average lifetime cost) or to filter with IN/EXISTS without needing columns from the other
   table. Use a join when I need columns from both tables in the output. (CTEs, coming on
   Day 2, make complex subqueries easier to read.)

4. **COUNT(*) vs COUNT(column)?**
   COUNT(*) counts all rows, including those with NULLs. COUNT(column) counts only rows
   where that column is not NULL. COUNT(DISTINCT column) counts unique non-NULL values.
   Example: COUNT(*) - COUNT(payer) gives the number of encounters with a missing payer.

## What I got wrong or forgot in my practice file
EDIT: Replace with what actually happened. Common ones to check against your own attempts:
- Forgot that HAVING (not WHERE) is needed to filter on an aggregate.
- Missed a column in GROUP BY, which gives the error "must appear in the GROUP BY clause".
- Used COUNT(*) where COUNT(DISTINCT patient) was needed, so the numbers were too high.
- Forgot the semicolon, or typed a table/column name wrong.
- Used JOIN where LEFT JOIN was needed.

My plan to fix it: retype the query I got wrong tomorrow, from the question only.
