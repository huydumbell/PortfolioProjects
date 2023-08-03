/*
Cleaning Data in SQL Queries
*/

Select * 
from PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------

-- Standardize Date format
Select SaleDateConverted, CONVERT(date, SaleDate)
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(date,SaleDate)

Alter table NashvilleHousing
Add SaleDateConverted Date;


Update NashvilleHousing
Set SaleDateConverted = CONVERT(date,SaleDate)

---------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on  a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress =  ISNULL (a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on  a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------

--Breaking out Address into Indivisuals columns (Adress, City, State)

Select PropertyAddress
from PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
--Orderby ParcelID

Select 
SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress) ) as Address

FROM PortfolioProject..NashvilleHousing

use PortfolioProject
go

Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);


Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress) -1 )

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);


Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress) )

Select * from PortfolioProject..NashvilleHousing


--Other way than substring
Select OwnerAddress
from PortfolioProject..NashvilleHousing

Select 
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)

Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);


Update NashvilleHousing
Set OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);


Update NashvilleHousing
Set OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)

Select * from PortfolioProject..NashvilleHousing


------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'Solid as Vacant' field

Select Distinct (SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2



SELECT SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   End
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   End


--------------------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE as (

Select *,
	ROW_NUMBER() over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
						UniqueID
						) row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID
) 
Delete from RowNumCTE
where row_num > 1
--order by PropertyAddress


----------------------------------------------------------------------------------------------------------------------------------------------

--Delete unused columns

select * from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject..NashvilleHousing
drop column SaleDate

