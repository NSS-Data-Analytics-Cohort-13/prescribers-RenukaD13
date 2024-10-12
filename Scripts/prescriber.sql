
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

SELECT COUNT(*) 
FROM fips_county AS f
INNER JOIN cbsa AS c
ON f.fipscounty = c.fipscounty
WHERE f.state = 'TN'
--Answer = There are 42 CBSA's present in Tennessee

-- Q5 b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT 
	cb.cbsaname, 
	SUM(p.population) as combined_population
FROM fips_county AS f
INNER JOIN cbsa AS cb 
	ON f.fipscounty = cb.fipscounty
INNER JOIN population AS p 
	ON f.fipscounty = p.fipscounty
WHERE f.state = 'TN' 
GROUP BY cb.cbsaname
ORDER BY combined_population
/* Answer largest combined population = "Nashville-Davidson_Murfreesboro-Franklin" and Total Population is "1830410"
  smallest combined population = "Morristown, TN" and Total Population is "116352" */
 
-- Q5 c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT 
	f.county, 
	SUM(p.population) as combined_population
FROM fips_county AS f
INNER JOIN population AS p 
	ON f.fipscounty = p.fipscounty
WHERE f.fipscounty IN
		--Subquery to return TN fipscounty which are not included in CBSA
		(SELECT fipscounty FROM fips_county WHERE STATE = 'TN' --fips_county table has 96 records for TN
		EXCEPT
		SELECT fipscounty FROM cbsa) --Total 54 fipscounty are not present in CBSA
GROUP BY f.county
ORDER BY combined_population desc
LIMIT 1
/* Answer = "SEVIER" county with 95523 population is the largest county in terms of population, which is not included in a CBSA*/

--Q6 a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name, total_claim_count 
FROM prescription 
WHERE total_claim_count >=3000
/* Answer : 9 rows*/

--Q6 b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT 
	p1.drug_name, 
	p1.total_claim_count, 
	d.opioid_drug_flag
FROM prescription AS p1
INNER JOIN drug AS d
	ON d.drug_name = p.drug_name 
WHERE p.total_claim_count >=3000

--Q6 c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT 
	p1.drug_name, 
	p1.total_claim_count, 
	d.opioid_drug_flag,
	p2.nppes_provider_first_name, 
	p2.nppes_provider_last_org_name
FROM prescription AS p1
INNER JOIN drug AS d
	ON d.drug_name = p1.drug_name 
INNER JOIN prescriber AS p2
	USING(npi)
WHERE p1.total_claim_count >=3000

--7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--Q7 a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.


 SELECT p1.npi, d.drug_name
, p1.nppes_provider_first_name, p1.nppes_provider_last_org_name
 FROM prescriber AS p1
 INNER JOIN prescription AS p2
 	USING(npi)
	INNER JOIN drug AS d
	ON p2.drug_name = d.drug_name 
 WHERE p1.specialty_description = 'Pain Management'
 AND p1.nppes_provider_city = 'NASHVILLE'
 order by 1,3,4
/*Answer = 89 rows*/

--Q7 b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT p1.npi, p2.drug_name, p2.total_claim_count
FROM prescriber AS p1
LEFT JOIN prescription AS p2 USING(npi)
WHERE p1.specialty_description = 'Pain Management'
AND p1.nppes_provider_city = 'NASHVILLE'

--Q7 c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
--Answer No NULL values found to convert it into 0






