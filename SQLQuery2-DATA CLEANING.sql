SELECT*
FROM PortfolioProject..NashvilleHousingcsv

--Standardize Sale Date
SELECT * 
FROM PortfolioProject..NashvilleHousingcsv

Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousingcsv
Update PortfolioProject..NashvilleHousingcsv
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE PortfolioProject..NashvilleHousingcsv
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousingcsv
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Populate PropertyAddress data
Select *
From PortfolioProject..NashvilleHousingcsv
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousingcsv a
JOIN PortfolioProject..NashvilleHousingcsv b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousingcsv a
JOIN PortfolioProject..NashvilleHousingcsv b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



--Breaking out PropertyAddress into Individual Columns (Address, City)
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousingcsv
ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',' , PropertyAddress)-1) as PropertyAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress)) as PropertyCity
FROM PortfolioProject..NashvilleHousingcsv

ALTER TABLE PortfolioProject..NashvilleHousingcsv
ADD PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject..NashvilleHousingcsv
SET PropertySplitAddress= SUBSTRING(PropertyAddress,1, CHARINDEX(',' , PropertyAddress)-1) 

ALTER TABLE PortfolioProject..NashvilleHousingcsv
ADD PropertySplitCity nvarchar(255);

UPDATE PortfolioProject..NashvilleHousingcsv
SET PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress)) 

SELECT *
FROM PortfolioProject..NashvilleHousingcsv



--Breaking out OwnerAddress into Individual Columns (Address, City, State)
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousingcsv

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM PortfolioProject..NashvilleHousingcsv

ALTER TABLE PortfolioProject..NashvilleHousingcsv
ADD OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject..NashvilleHousingcsv
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE PortfolioProject..NashvilleHousingcsv
ADD OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject..NashvilleHousingcsv
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE PortfolioProject..NashvilleHousingcsv
ADD OwnerSplitState nvarchar(255);

UPDATE PortfolioProject..NashvilleHousingcsv
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

SELECT*
FROM PortfolioProject..NashvilleHousingcsv


-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousingcsv
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE
WHEN SoldAsVacant=1 THEN 'Yes' ELSE 'No'
END
FROM PortfolioProject..NashvilleHousingcsv

ALTER TABLE PortfolioProject..NashvilleHousingcsv
ADD SoldAsVacantCorrected nvarchar(255);

UPDATE PortfolioProject..NashvilleHousingcsv
SET SoldAsVacantCorrected= CASE
WHEN SoldAsVacant=1 THEN 'Yes' ELSE 'No'
END

SELECT DISTINCT(SoldAsVacantCorrected), COUNT(SoldAsVacantCorrected)
FROM PortfolioProject..NashvilleHousingcsv
GROUP BY SoldAsVacantCorrected



--Removing Duplicates (You shouldn't do this to your Database, except otherwise required)
SELECT*
FROM PortfolioProject..NashvilleHousingcsv

WITH RowNumCTE as
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference,OwnerName, OwnerAddress, Acreage,TaxDistrict,Bedrooms, FullBath,HalfBath
ORDER BY UniqueID ) as row_num
FROM PortfolioProject..NashvilleHousingcsv
)
--ORDER BY ParcelID 
SELECT* 
--DELETE
FROM RowNumCTE
WHERE row_num>1
--ORDER BY PropertyAddress


--Delete Unused Columns 
SELECT*
FROM PortfolioProject..NashvilleHousingcsv

ALTER TABLE PortfolioProject..NashvilleHousingcsv
DROP COLUMN   SoldAsVacant, TaxDistrict