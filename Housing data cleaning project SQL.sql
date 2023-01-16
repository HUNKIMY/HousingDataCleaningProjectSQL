--cleaning data in sql queries

Select *
From portfolio2.dbo.NashvilleHousing

--Standardize date format
Select SaleDateConverted, CONVERT(Date, SaleDate)
From portfolio2.dbo.NashvilleHousing

ALTER TABLE portfolio2.dbo.NashvilleHousing
ADD SaleDateConverted Date;


 

Update portfolio2.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--populate property address data


Select *
From portfolio2.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolio2.dbo.NashvilleHousing a
JOIN portfolio2.dbo.NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set propertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolio2.dbo.NashvilleHousing a
JOIN portfolio2.dbo.NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is null

--delete duplicate
WITH CTE AS
(
SELECT *,ROW_NUMBER() OVER (PARTITION BY UniqueID ORDER BY UniqueID) AS RN
FROM portfolio2.dbo.NashvilleHousing
)

DELETE FROM CTE WHERE RN<>1

--break out address into individual columns (address, city, state)
Select PropertyAddress
From portfolio2.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address 

From portfolio2.dbo.NashvilleHousing

ALTER TABLE portfolio2.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update portfolio2.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE portfolio2.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update portfolio2.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From portfolio2.dbo.NashvilleHousing

Select OwnerAddress
From portfolio2.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
From portfolio2.dbo.NashvilleHousing

ALTER TABLE portfolio2.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update portfolio2.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE portfolio2.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update portfolio2.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE portfolio2.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update portfolio2.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From portfolio2.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
From portfolio2.dbo.NashvilleHousing

Update portfolio2.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END


--Remove Duplicate
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				 UniqueID
				 ) row_num
From portfolio2.dbo.NashvilleHousing
)


Select *
From RowNumCTE
Where row_num > 1

--Delete Unsed Columns
Select *
From portfolio2.dbo.NashvilleHousing

ALTER TABLE portfolio2.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE portfolio2.dbo.NashvilleHousing
DROP COLUMN SaleDate
