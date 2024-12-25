select * from dbo.Nashville_data_cleaning

select SaleDate, CONVERT(Date, SaleDate)
from dbo.Nashville_data_cleaning

Update Nashville_data_cleaning
set SaleDate = Convert(Date, SaleDate)

--- Populate property address Data where there is null--------------------------------------------------------------------------------------------
select PropertyAddress
from dbo.Nashville_data_cleaning
where PropertyAddress is null

select a.ParcelID,a.PropertyAddress, b.PropertyAddress, b.ParcelID, isnull(a.PropertyAddress, b.PropertyAddress) from dbo.Nashville_data_cleaning a 
join dbo.Nashville_data_cleaning b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from dbo.Nashville_data_cleaning a 
join dbo.Nashville_data_cleaning b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--update Acerage to float and round to 2 decimals--------------------------------------------------------------------------------------------
update Nashville_data_cleaning
set Acreage = round(cast(Acreage as float),2)


-- Breaking out Address into Individual Columns (Address, city, state)--------------------------------------------------------------------------------------------

select PropertyAddress
from dbo.Nashville_data_cleaning 

select
substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as street,
substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress)) as city
from dbo.Nashville_data_cleaning 

Alter table Nashville_data_cleaning 
add PropertySplitAddress Nvarchar(255)

update Nashville_data_cleaning
set PropertySplitAddress = substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

Alter table Nashville_data_cleaning 
add PropertySplitcity Nvarchar(255)

update Nashville_data_cleaning
set PropertySplitcity = substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress)) 

--- change Y and N to YES and NO in 'Sold as vacant' field--------------------------------------------------------------------------------------------


 select  Distinct(SoldAsVacant) ,count(SoldAsVacant) vacnt
 from dbo.Nashville_data_cleaning 
 group by SoldAsVacant

 select  
 SoldAsVacant,

case when SoldAsVacant ='Y' then 'Yes'
when SoldAsVacant ='N' then 'No'
else SoldAsVacant end

 from dbo.Nashville_data_cleaning 

 update Nashville_data_cleaning 
 set SoldAsVacant =

case when SoldAsVacant ='Y' then 'Yes'
when SoldAsVacant ='N' then 'No'
else SoldAsVacant end


 -- Remove duplicates----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 with CTE_ranking as 
 (select *,
 ROW_NUMBER() over(partition by ParcelID, PropertyAddress, Saleprice, Saledate, LegalReference
 order by UniqueID) ranking
  from dbo.Nashville_data_cleaning)


select *  from CTE_ranking
where ranking > 1

-----Delete unused columns-------------------------------------------------------------------------------------------------------------------------------------------

select * from dbo.Nashville_data_cleaning
alter table Nashville_data_cleaning
drop column Saledate, OwnerAddress, PropertyAddress, TaxDistrict