


Select *
From PortfolioProject1..NashvilleHousing

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject1..NashvilleHousing

UPDATE PortfolioProject1..NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE PortfolioProject1..NashvilleHousing
Add SaleDateConverted Date;

UPDATE PortfolioProject1..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)




-- Populate Property Address Data

Select *
From PortfolioProject1..NashvilleHousing


-- Where PropertyAddress is null

order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1..NashvilleHousing a
JOIN PortfolioProject1..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1..NashvilleHousing a
JOIN PortfolioProject1..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




-- Breaking out Address into Individual COlumns (Address, City, State)

Select PropertyAddress
From PortfolioProject1..NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject1..NashvilleHousing


ALTER TABLE PortfolioProject1..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject1..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProject1..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject1..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select * 
From PortfolioProject1..NashvilleHousing



Select OwnerAddress
From PortfolioProject1..NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3 )
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2 )
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1 )
From PortfolioProject1..NashvilleHousing


-- Owner Split Adress
ALTER TABLE PortfolioProject1..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject1..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3 )


-- Owner Split City
ALTER TABLE PortfolioProject1..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject1..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2 )


-- Owner Split State
ALTER TABLE PortfolioProject1..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject1..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1 )

Select * 
From PortfolioProject1..NashvilleHousing




-- Change Y and N to Yes and No in "Sold as Vacant" filed

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject1..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject1..NashvilleHousing


UPDATE PortfolioProject1..NashvilleHousing
SET SoldAsVacant =  CASE When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant
		END




-- Remove Duplicates (Usually we do not delete data, raw data that is not going to be used yet shoulld never be deleted)

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
				 ) row_num

From PortfolioProject1..NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1

-- finding id everything was deleted just have to replace it with the DELETE format

Select *
From RowNumCTE
Where row_num > 1
order by PropertyAddress




-- Delete Unused Columns

Select * 
From PortfolioProject1..NashvilleHousing

ALTER TABLE PortfolioProject1..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject1..NashvilleHousing
DROP COLUMN SaleDate
