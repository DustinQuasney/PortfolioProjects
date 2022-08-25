-------------------------
--DATA CLEANING QUERIES--
-------------------------

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

---------------------------
--STANDARDIZE DATE FORMAT--
---------------------------

SELECT SaleDateConverted, CONVERT(Date, SaleDate)

FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate=CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted=CONVERT(Date, SaleDate)

----------------------------------
--POPULATE PROPERTY ADDRESS DATA--
----------------------------------

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)

FROM PortfolioProject.dbo.NashvilleHousing AS A
JOIN PortfolioProject.dbo.NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]

WHERE A.PropertyAddress IS NULL

UPDATE A

SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)

FROM PortfolioProject.dbo.NashvilleHousing AS A
JOIN PortfolioProject.dbo.NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]

WHERE A.PropertyAddress IS NULL

-----------------------------------------------------------------------
--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)--
-----------------------------------------------------------------------

--BREAKING OUT ADDRESS AND CITY FROM PROPERTY ADDRESS--

SELECT

SUBSTRING(PROPERTYADDRESS, 1, CHARINDEX(',',PropertyAddress) -1) AS [Address],
SUBSTRING(PROPERTYADDRESS, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS [Address]

FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PROPERTYADDRESS, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity=SUBSTRING(PROPERTYADDRESS, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

--BREAKING OUT ADDRESS, CITY, AND STATE FROM OWNER ADDRESS--

SELECT

PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS OwnerCity,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS OwnerState

FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--------------------------------------------------------------
--Change Y and N to Yes and No in the "Sold as Vacant" Field--
--------------------------------------------------------------

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) AS [Count]

FROM PortfolioProject.dbo.NashvilleHousing

GROUP BY SoldAsVacant

ORDER BY 2

SELECT

SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END AS VacantUpdate

FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing

SET SoldAsVacant =  CASE 
					WHEN SoldAsVacant = 'Y' THEN 'Yes'
					WHEN SoldAsVacant = 'N' THEN 'No'
					ELSE SoldAsVacant
					END

---------------------
--REMOVE DUPLICATES--
---------------------

WITH RowNumCTE AS (

SELECT
*,
ROW_NUMBER() OVER(

PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference

			 ORDER BY
				UniqueID
				) Row_Num

FROM PortfolioProject.dbo.NashvilleHousing

)

DELETE

FROM RowNumCTE

WHERE Row_Num > 1

-------------------------
--DELETE UNUSED COLUMNS--
-------------------------

SELECT * FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate, PropertyAddress, TaxDistrict, OwnerAddress