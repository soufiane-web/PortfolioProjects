/*

Cleaning Data in SQL Queries

*/

select * from NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format  (SaleDate column)

select * from NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate);

SELECT SaleDate,CONVERT(date, SaleDate) AS SaleDateFormatted
FROM NashvilleHousing;


 -----------------------------------------------------------------------------------
-- Populate Property Address data

select PropertyAddress 
from NashvilleHousing

select * 
from NashvilleHousing
order by UniqueID

--si on a 2 enregistrements avec le meme parcelID et un de ces 2 n'a pas PropertyAddress
-- => lui donner la meme PropertyAddress

select a.parcelid,a.propertyaddress, 
	   b.parcelid,b.propertyaddress,
	   ISNULL(a.propertyaddress,b.propertyaddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.UniqueID <> b.UniqueID
where a.propertyaddress is null



--=> Update (no column name)=> propertyaddress
/* joins in update statement ,we should use alias to dont get error */

update a
set propertyaddress=ISNULL(a.propertyaddress,b.propertyaddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.UniqueID <> b.UniqueID
where a.propertyaddress is null


--------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

Select PropertyAddress,
	   SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
	   SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
From NashvilleHousing 

--create 2 new columns pour separer addresse


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255),
    PropertySplitCity NVARCHAR(255);

---methode1:Substring
update NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
	PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

---methode2:Parsename(il marche que avec '.' et avec des indices inversé)
select * from NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
    OwnerSplitCity NVARCHAR(255),
	OwnerSplitState NVARCHAR(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)  ,
	OwnerSplitCity    = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)  ,
	OwnerSplitState	  = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field
select distinct SoldasVacant,count(SoldasVacant) 
from NashvilleHousing
group by SoldasVacant
order by count(SoldasVacant) 

select SoldasVacant, 
CASE 
    WHEN SoldasVacant='n' THEN 'No'
    WHEN SoldasVacant='y' THEN 'Yes'
	else SoldasVacant
END as YN
from NashvilleHousing

update NashvilleHousing
set SoldasVacant= CASE 
    WHEN SoldasVacant='n' THEN 'No'
    WHEN SoldasVacant='y' THEN 'Yes'
	else SoldasVacant
	end

----------------------------------------------------------------
-- Remove Duplicates 

with RowNumCTE as(
select *,
	   ROW_NUMBER() OVER (
			PARTITION BY parcelid,
						propertyaddress,
						saleprice,
						saledate,
						legalreference 
			 ORDER BY uniqueId ) row_num
from NashvilleHousing
)
select * from RowNumCTE
where row_num>1

--delete  from RowNumCTE
--where row_num>1









