/*
Cleaning Data in SQL Queries
*/


Select *
From PortfolioProject.dbo.Nashvillehousing



-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.Nashvillehousing

Update Nashvillehousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Nashvillehousing
Add SaleDateConverted Date;

Update Nashvillehousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



--Populate Property Address data

Select *
From PortfolioProject.dbo.Nashvillehousing
---where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.Nashvillehousing a
JOIN PortfolioProject.dbo.Nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.Nashvillehousing a
JOIN PortfolioProject.dbo.Nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.Nashvillehousing
---where PropertyAddress is null
--Order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.Nashvillehousing


ALTER TABLE PortfolioProject.dbo.Nashvillehousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject.dbo.Nashvillehousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.Nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.Nashvillehousing






Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
From PortfolioProject.dbo.Nashvillehousing



ALTER TABLE PortfolioProject.dbo.Nashvillehousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.Nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE PortfolioProject.dbo.Nashvillehousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.Nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE PortfolioProject.dbo.Nashvillehousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.Nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


Select *
From PortfolioProject.dbo.Nashvillehousing




--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.Nashvillehousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From PortfolioProject.dbo.Nashvillehousing


Update PortfolioProject.dbo.Nashvillehousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END






----Remove Duplicates

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
					)row_num

From PortfolioProject.dbo.Nashvillehousing
--Order by ParcelID
)
Select *
--DELETE
From RowNumCTE
where row_num > 1
--order by PropertyAddress




-- Delete Unused Columns

Select *
From PortfolioProject.dbo.Nashvillehousing

ALTER TABLE PortfolioProject.dbo.Nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.Nashvillehousing
DROP COLUMN SaleDate
