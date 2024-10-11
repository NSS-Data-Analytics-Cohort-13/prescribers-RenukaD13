SELECT * FROM prescription
--Answer 656058 total rows

--Query to see a data of a prescriber for each drug prescribed
SELECT 
	npi, drug_name, total_claim_count, nppes_provider_last_org_name, nppes_provider_first_name  
	FROM prescriber 
INNER JOIN prescription 
	USING (npi)
WHERE prescriber.npi = 1881634483
ORDER BY total_claim_count DESC

--Query to find out if there are drugs whose total cost is not equal to total cost of ge65
SELECT npi, total_drug_cost, total_drug_cost_ge65 
	FROM prescription 
WHERE ge65_suppress_flag IS NULL 
	AND total_drug_cost <> total_drug_cost_ge65
--Answer 197492 rows have diffrent values of total drug cost

--Q1 a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, total_claims 
FROM (
	SELECT 
		p1.npi, 
		--total claims totaled over all drugs for 65 years old and below
		SUM(p2.total_claim_count) AS total_claims 
	FROM prescriber AS p1
		INNER JOIN prescription AS p2
		USING(npi)
	GROUP BY p1.npi --Filter data based on npi(National provider identifier)
UNION ALL
	SELECT 
		p1.npi, 
		--total claims totaled over all drugs for 65 years old and above
		SUM(p2.total_claim_count_ge65) AS total_claims 
	FROM prescriber AS p1
		INNER JOIN prescription AS p2
		USING(npi)
	WHERE ge65_suppress_flag IS NULL 
		AND total_drug_cost <> total_drug_cost_ge65
	GROUP BY p1.npi
	) 
ORDER BY total_claims DESC  --Filter data based on npi(National provider identifier))
LIMIT 1;
--Answer npi =1881634483 have highest total number of claims= 99707 
--Total 33964 records withought limit 1
