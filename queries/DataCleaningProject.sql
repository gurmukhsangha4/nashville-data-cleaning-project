
/*

Cleaning Data in SQL Queries

*/

Select * 
From [Data Cleaning].dbo.[NashvilleHousingData]

------------------------------------------------------------
-- Standardize Date Format 
Select SaleDate, CONVERT(Date,SaleDate)                                                                                          
From [Data Cleaning].dbo.[NashvilleHousingData]
                                                            
Update [NashvilleHousingData]
SET SaleDate = CONVERT(Date, SaleDate)      

ALTER TABLE [NashvilleHousingData]   
Add SaleDateConverted Date; 

Update [NashvilleHousingData]
Set SaleDateConverted = CONVERT(Date, SaleDate)  

------------------------------------------------------------
-- Populate Property Address Data  
Select *                                                                                     
From [Data Cleaning].dbo.[NashvilleHousingData]
-- Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)                                                                            
From [Data Cleaning].dbo.[NashvilleHousingData] a 
JOIN [Data Cleaning].dbo.[NashvilleHousingData] b
    on a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Data Cleaning].dbo.[NashvilleHousingData] a 
JOIN [Data Cleaning].dbo.[NashvilleHousingData] b
    on a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is NULL

------------------------------------------------------------
-- Breaking out Address into Individual Comlumns (Address, City, State) 

Select PropertyAddress                                                                                 
From [Data Cleaning].dbo.[NashvilleHousingData]

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From [Data Cleaning].dbo.[NashvilleHousingData]

ALTER TABLE [NashvilleHousingData]   
Add PropertySplitAddress NVARCHAR(255); 

Update [NashvilleHousingData]
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 


ALTER TABLE [NashvilleHousingData]   
Add PropertySplitCity NVARCHAR(255); 

Update [NashvilleHousingData]
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

------------------------------------------------------------
-- Populate the Owner Address
Select 
 PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)  
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)                 
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)                                                                       
From [Data Cleaning].dbo.[NashvilleHousingData]

ALTER TABLE [NashvilleHousingData]   
Add OwnerSplitAddress NVARCHAR(255); 

Update [NashvilleHousingData]
Set OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)  


ALTER TABLE [NashvilleHousingData]   
Add OwnerSplitCity NVARCHAR(255); 

Update [NashvilleHousingData]
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)                 

ALTER TABLE [NashvilleHousingData]   
Add OwnerSplitState NVARCHAR(255); 

Update [NashvilleHousingData]
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)  

------------------------------------------------------------
-- Change Y and N to Yes and No in 'Sold as Vacant' Field   
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [Data Cleaning].dbo.[NashvilleHousingData]
Group By SoldAsVacant
ORDER BY 2

Select SoldAsVacant,
    CASE 
    When SoldAsVacant = 'Y' THEN 'Yes'
    When SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END 
From [Data Cleaning].dbo.[NashvilleHousingData]

Update [NashvilleHousingData]
SET SoldAsVacant =  CASE 
    When SoldAsVacant = 'Y' THEN 'Yes'
    When SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END 

------------------------------------------------------------
-- Remove Duplicates
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
From [Data Cleaning].dbo.[NashvilleHousingData]
)
DELETE 
From RowNumCTE
Where row_num > 1


------------------------------------------------------------
-- Delete Unused Columns 

Select * 
From [Data Cleaning].dbo.[NashvilleHousingData]

ALTER TABLE [Data Cleaning].dbo.[NashvilleHousingData]
DROP COLUMN OwnerAddress,  TaxDistrict, PropertyAddress

ALTER TABLE [Data Cleaning].dbo.[NashvilleHousingData]
DROP COLUMN SaleDate












------------------------------------------------------------
