USE NashvilleHousing;
-- Data Cleaning
----------------------------------------------

Select * From HousingData;
--Standardize Data
ALTER TABLE HousingData
ADD SaleDateConverted Date;

Update HousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address data

Select PropertyAddress FROM HousingData
WHERE PropertyAddress IS NULL;

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM HousingData A
JOIN HousingData B ON A.ParcelID = B.ParcelID
AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL;
--filling in Null Property Address
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM HousingData A
JOIN HousingData B ON A.ParcelID = B.ParcelID
AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL;

--Break Out Address into  Individual Columns(Address,City,State)

Select PropertyAddress FROM HousingData;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) AS Address
FROM HousingData  

ALTER TABLE HousingData
ADD PropertySplitAddress Nvarchar(255);

Update HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE HousingData
ADD PropertySplitCity Nvarchar(255);

Update HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))

Select * From HousingData;

--Now New Columns Seperated by City and Address 

--Now Deal with OwnerAddress Breaking into Address, City, State

SELECT OwnerAddress From HousingData;

SELECT 
PARSENAME (REPLACE(OwnerAddress, ',','.'), 3 ),
PARSENAME (REPLACE(OwnerAddress, ',','.'), 2 ),
PARSENAME (REPLACE(OwnerAddress, ',','.'), 1 )
FROM HousingData



ALTER TABLE HousingData
ADD OwnerSplitAddress Nvarchar(255);

Update HousingData
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',','.'), 3 )

ALTER TABLE HousingData
ADD OwnerSplitCity Nvarchar(255);

Update HousingData
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',','.'), 2 )

ALTER TABLE HousingData
ADD OwnerSplitState Nvarchar(100);

Update HousingData
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',','.'), 1 )

--Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) AS counts
FROM HousingData
GROUP BY SoldAsVacant
ORDER BY counts;

UPDATE HousingData 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END;

---Remove Duplicates in HousingData
WITH RowNumCTE AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY ParcelID,
                        PropertyAddress,
                        SalePrice,
                        SaleDate,
                        LegalReference
           ORDER BY UniqueID
         ) row_num
  FROM HousingData
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1 --would be a duplicate
ORDER BY PropertyAddress;

--Delete Unused Column Fields

Select * From HousingData;

ALTER TABLE HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



