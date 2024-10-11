
--Q1 a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT 
	p1.npi, 
	SUM(p2.total_claim_count) AS total_claims --total claims, totaled over all drugs
FROM prescriber AS p1
	INNER JOIN prescription AS p2
USING(npi)
GROUP BY p1.npi --Filter data based on npi(National provider identifier)
ORDER BY total_claims DESC -- Sort data by total number of claims for all drugs in descending order 
LIMIT 1; --(Withought Limit 1 - Total 20592 records)

/*Answer Q1a= npi 1881634483 have highest total number of claims= 99707 (totaled over all drugs)*/

--Q1 b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT 
	p1.nppes_provider_first_name, 
	p1.nppes_provider_last_org_name, 
	p1.specialty_description,  
	SUM(p2.total_claim_count) AS total_claims --total claims, totaled over all drugs
FROM prescriber AS p1
INNER JOIN prescription AS p2
	USING(npi)
GROUP BY --Filter data based on providers first & last name along with speciality description
	p1.nppes_provider_first_name, 
	p1.nppes_provider_last_org_name, 
	p1.specialty_description
ORDER BY total_claims DESC -- Sort data by total number of claims for all drugs in descending order
LIMIT 1;

/*Answer Q1b= Prescriber "BRUCE PENDLEY", specialised in "Family Practice" has highest numer of claims, totaled over all the drugs.*/

--Q2  a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT 
	p1.specialty_description,
	SUM(p2.total_claim_count) AS total_claims --total claims, totaled over all drugs
FROM prescriber AS p1
INNER JOIN prescription AS p2
	USING(npi)
GROUP BY 
	p1.specialty_description --Filter data based on speciality type
ORDER BY total_claims DESC -- Sort data by total number of claims for all drugs in descending order
LIMIT 1;

/* Answer Q2a= "Family Practice" specialty had 9752347 claims (totaled over all drugs)*/

--Q2 b. Which specialty had the most total number of claims for opioids?

SELECT 
	p1.specialty_description,
	SUM(p2.total_claim_count) AS total_claims --total claims, totaled over all drugs
FROM prescriber AS p1
INNER JOIN prescription AS p2
	USING(npi)
INNER JOIN drug AS d
	ON p2.drug_name = d.drug_name
	WHERE d.opioid_drug_flag = 'Y' --Filter data for drugs which are flagged as opiod
GROUP BY 
	p1.specialty_description --Filter data based on speciality type
ORDER BY total_claims DESC -- Sort data by total number of claims for all drugs in descending order
LIMIT 1

/* Answer "Nurse Practitioner" had the most total number of claims for opioids which is 900845*/

--Q3 a. Which drug (generic_name) had the highest total drug cost?

SELECT 
	d.generic_name,
	ROUND(p1.total_drug_cost,2) :: MONEY AS total_drug_cost
FROM drug AS d
INNER JOIN prescription AS p1
	ON d.drug_name = p1.drug_name 
GROUP BY 
	d.generic_name,
	p1.total_drug_cost
ORDER BY total_drug_cost desc--Sort data by total drug cost in descending order 2829174.3
LIMIT 1 
/* Answer = "PIRFENIDONE" had the highest total drug cost 2829174.30*/

--Q3 b. Which drug (generic_name) has the hightest total cost per day? 

SELECT 
	d.generic_name,
	ROUND((p1.total_drug_cost/p1.total_day_supply),2) :: MONEY AS total_cost_per_day
FROM drug AS d
INNER JOIN prescription AS p1
	ON d.drug_name = p1.drug_name 
GROUP BY 
	d.generic_name,
	total_cost_per_day
ORDER BY total_cost_per_day desc--Sort data by total drug cost in descending order 2829174.3
LIMIT 1 
-- Or Can my do total cost per day = total_drug_cost / total_day supply?
select * from prescription

--4. a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. 

SELECT drug_name,
	CASE 
		WHEN d1.opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN d1.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither' 
		END AS drug_type
FROM drug AS d1
/*Answer 4a= 3425 rows*/

/* Investigating answer with following queries: 
If we run above query with distinct(drug_name), number of rows returned are 3260, which are 7 extra rows. It's because drug_name Sodium chloride(7 rows), has different generic names, so is different.
select distinct(drug_name) from drug = 3253 
select * from drug = 3425 rows
*/

--Q4 b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT 
	CASE 
		WHEN d1.opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN d1.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither' 
		END AS drug_type,
		SUM(p1.total_drug_cost) :: MONEY AS p1cost
FROM drug AS d1
INNER JOIN prescription AS p1 	
	ON d1.drug_name = p1.drug_name 
GROUP BY drug_type  
/* Answer: "antibiotic"	= 38435121.26, "neither" = 2972698710.23, "opioid" = 105080626.37*/

--Q5 a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

--SELECT COUNT(*) cbsa_tn_count
SELECT * 
FROM cbsa 
WHERE cbsaname LIKE ('%TN%')
/*Answer = There are 56 CBSA's present in Tennessee*/

-- Q5 b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT 
	c.cbsaname, 
	SUM(p.population) as total_population
FROM cbsa AS c
LEFT JOIN zip_fips as z
	ON c.fipscounty = z.fipscounty
JOIN population AS p
	ON  z.fipscounty =  p.fipscounty
WHERE c.cbsaname LIKE ('%TN%')
GROUP BY c.cbsaname
ORDER BY total_population DESC
--Answer largest combined population = "Memphis, TN-MS-AR" and Total Population is "67870189"
--  largest combined population = "Morristown, TN" and Total Population is "1163520"

-- Q5 c.What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.






