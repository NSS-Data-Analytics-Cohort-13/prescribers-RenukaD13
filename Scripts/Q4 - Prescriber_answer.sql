--Q4 b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT distinct(d1.drug_name),
	CASE 
		WHEN d1.opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN d1.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither' 
		END AS drug_type,
		sum(p1.total_drug_cost)  as p1cost,
		sum(p2.total_drug_cost) as p2cost
FROM drug AS d1
INNER JOIN prescription AS p1 	ON d1.drug_name = p1.drug_name AND d1.opioid_drug_flag = 'Y' 
INNER JOIN prescription AS p2 	ON d1.drug_name = p2.drug_name AND d1.antibiotic_drug_flag = 'Y'
group by d1.drug_name, drug_type


/* query to find value of opiod drug type*/
SELECT 'opioid' AS drug_type,--365580.05
	ROUND(p1.total_drug_cost,2) AS total_drug_cost
FROM drug AS d
INNER JOIN prescription AS p1
	ON d.drug_name = p1.drug_name 
	where d.opioid_drug_flag = 'Y' 
GROUP BY 
	p1.total_drug_cost
ORDER BY total_drug_cost desc--Sort data by total drug cost in descending order 2829174.3
LIMIT 1 

/* query to find value of antibiotic drug type*/
SELECT  'antibiotic' AS drug_type,--357176.96
	ROUND(p1.total_drug_cost,2) AS total_drug_cost
FROM drug AS d
INNER JOIN prescription AS p1
	ON d.drug_name = p1.drug_name 
	where d.antibiotic_drug_flag = 'Y' 
GROUP BY 
	p1.total_drug_cost
ORDER BY total_drug_cost desc--Sort data by total drug cost in descending order 2829174.3
LIMIT 1 