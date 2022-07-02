
/*
			Cleaning Data in SQL Queries
			& 
			ETL
*/

/* SELECT TOP(1000) [UniqueID]
		,[SaleDate]
		,[OwnerName]
FROM [PortfolioProject].[dbo].[HousingProject]
*/

--------------------------------------------------------------------------------------------------------
--show table
SELECT * 
FROM PortfolioProject..HousingProject
--or
SELECT * FROM PortfolioProject.dbo.HousingProject
------------------------------------------------------------------------------------------------

--										Standardize data Format
SELECT SaleDate--, CONVERT(Date,SaleDate)
FROM PortfolioProject..HousingProject
/*
UPDATE HousingProject
SET SaleDate = CONVERT(Date,SaleDate)
*/
--Alternative method to add a column from clean saledate
ALTER TABLE HousingProject
ADD SaleDateConverted Date;  -- adding column

Update HousingProject
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject..HousingProject  --working
--------------------------------------------------------------------------------------------------------
--									Populate Property Address data
SELECT PropertyAddress
FROM portfolioProject..HousingProject
--WHERE PropertyAddress is null
order by ParcelID       --Issue with same parcelID & PropertyAdress
---------------------------------------------------------------------
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolioProject..HousingProject a
JOIN PortfolioProject..HousingProject b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Solution
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolioProject..HousingProject a
JOIN PortfolioProject..HousingProject b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null       --Working


select PropertyAddress FROM PortfolioProject..HousingProject
Where PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------
--			Breaking Addrress Column into [Address], [City] , [State]


select PropertyAddress 
FROM PortfolioProject..HousingProject
--Where PropertyAddress is null

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,  CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as city
FROM PortfolioProject..HousingProject

--Solution

ALTER TABLE PortfolioProject..HousingProject
ADD PropertySplitAddress Nvarchar(255)

Update PortfolioProject..HousingProject
SET PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject..HousingProject
ADD PropertySplitCity Nvarchar(255)

Update PortfolioProject..HousingProject
SET PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

--Show Table
Select * FROM PortfolioProject..HousingProject

-------------------------------------------------
--				OwnerProperty Adress Breaking
Select * --OwnerAddress
 FROM PortfolioProject..HousingProject

 SELECT 
 PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
 , PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
 , PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
  FROM PortfolioProject..HousingProject


ALTER TABLE PortfolioProject..HousingProject
ADD OwnersplitAddress Nvarchar(255)

Update PortfolioProject..HousingProject
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE PortfolioProject..HousingProject
ADD OwnerSplitCity Nvarchar(255)

Update PortfolioProject..HousingProject
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE PortfolioProject..HousingProject
ADD OwnerSplitState Nvarchar(255)

Update PortfolioProject..HousingProject
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

--------------------------------------------------------------------------------------------------------------------
--					Set Yes or No for Y or N in "sold as vacant
SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..HousingProject
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
,CASE When SoldAsVacant = 'Y' THEN 'Yes'
	  When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
From PortfolioProject..HousingProject

--Solution
Update PortfolioProject..HousingProject
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	  When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END


-----------------------------------------------------------------------------------------------------------
--						Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 Legalreference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject..HousingProject
--order by ParcelID
)
SELECT * FROM RowNumCTE
WHERE row_num > 1
Order by PropertyAddress   --Cheecking & found 104 duplicates rows

--- solution
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 Legalreference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject..HousingProject
)
DELETE FROM RowNumCTE --delete 104 dublicate rows
WHERE row_num > 1      

--------------------------------------------------------------------------------------------------------------------
--					DELETE UNUSED COLUMN

ALTER TABLE PortfolioProject..HousingProject
DROP COLUMN OwnerAddress, PropertyAddress,SaleDate     --OwnerAddress, propertyAddress are splited & Data is Converted to simple format



SELECT * From PortfolioProject..HousingProject