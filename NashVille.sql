/*
Cleaning Data in SQL Queries
*/


select * from PortfolioProjects..NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SalesDateConverted, CONVERT(date,SaleDate) AS NewDate from PortfolioProjects..NashvilleHousing

Update NashvilleHousing
set SaleDate = CONVERT(date,SaleDate)

Alter table NashvilleHousing
Add SalesDateConverted Date;

Update NashvilleHousing
set SalesDateConverted = CONVERT(date,SaleDate)




 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select * from PortfolioProjects..NashvilleHousing order by ParcelID  

select Nash1.ParcelID, Nash1.PropertyAddress, Nash2.ParcelID, Nash2.PropertyAddress, ISNULL(Nash1.PropertyAddress,Nash2.PropertyAddress)
from PortfolioProjects..NashvilleHousing Nash1
 Join  PortfolioProjects..NashvilleHousing Nash2
 on Nash1.ParcelID = Nash2.ParcelID
 and Nash1.[UniqueID ] <> Nash2.[UniqueID ]
 where Nash1.PropertyAddress is null

 
 Update Nash1
 Set PropertyAddress =  ISNULL(Nash1.PropertyAddress,Nash2.PropertyAddress)
 from PortfolioProjects..NashvilleHousing Nash1
 Join  PortfolioProjects..NashvilleHousing Nash2
 on Nash1.ParcelID = Nash2.ParcelID
 and Nash1.[UniqueID ] <> Nash2.[UniqueID ]
 where Nash1.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


select PropertyAddress from PortfolioProjects..NashvilleHousing -- order by ParcelID  

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address -- the charindex specifies position
FROM PortfolioProjects..NashvilleHousing

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1 ) as Address ,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as Address
FROM PortfolioProjects..NashvilleHousing



Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1 )


Alter table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))




Select OwnerAddress FROM PortfolioProjects..NashvilleHousing 

Select
PARSENAME (Replace(OwnerAddress,',','.') ,3),
PARSENAME (Replace(OwnerAddress,',','.') ,2),        --Parsename normally selects from behind hence the reason have done in desc order
PARSENAME (Replace(OwnerAddress,',','.') ,1)

 FROM PortfolioProjects..NashvilleHousing

 

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME (Replace(OwnerAddress,',','.') ,3)

Alter table NashvilleHousing
Add  OwnerSplitCity nvarchar(255);

Update NashvilleHousing
set  OwnerSplitCity = PARSENAME (Replace(OwnerAddress,',','.') ,2)

Alter table NashvilleHousing
Add  OwnerSplitState nvarchar(255);

Update NashvilleHousing
set  OwnerSplitState = PARSENAME (Replace(OwnerAddress,',','.') ,1)



select * FROM PortfolioProjects..NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from  PortfolioProjects..NashvilleHousing
Group BY SoldAsVacant
Order by 2


Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No' 
	 Else SoldAsVacant
	 END
from  PortfolioProjects..NashvilleHousing



update NashvilleHousing
set SoldAsVacant =

Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No' 
	 Else SoldAsVacant
	 END

	 
Select * from  PortfolioProjects..NashvilleHousing 



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE AS(

Select *,
 ROW_NUMBER() over (
 Partition by ParcelID,
			  PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			 ORDER BY
			     UniqueID
				 ) row_num
    

from  PortfolioProjects..NashvilleHousing 
-- ORDER BY ParcelID
)
Select *from RowNumCTE
 where row_num > 1
 Order by PropertyAddress





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select * from  PortfolioProjects..NashvilleHousing 

Alter table PortfolioProjects..NashvilleHousing 
Drop Column OwnerAddress, PropertyAddress, TaxDistrict

Alter table PortfolioProjects..NashvilleHousing 
Drop Column SaleDate








