drop table if exists Hospital
create table Hospital(
	HospitalId int not null primary key,
	HospitalSize int not null unique,
	HospitalName varchar(255)
)

drop table if exists Doctors 
create table Doctors(
	DoctorId int not null primary key,
	DoctorPatientNumber int not null,
	DoctorName varchar(255)
)

drop table if exists WorkPlace 
create table WorkPlace(
	HospitalId int not null references Hospital(HospitalId),
	DoctorId int not null  references Doctors(DoctorId),
	WorkPlaceId int not null primary key
)

drop table HospitalName
create table HospitalName(
	Id int not null,
	HospitalName varchar(255)
)

drop table HospitalSize
create table HospitalSize(
	Id int not null primary key,
	Size int not null unique
)

insert into HospitalName(Id,HospitalName) values (1,'Constantin Opris')
insert into HospitalName(Id,HospitalName) values (2,'Elias')
insert into HospitalName(Id,HospitalName) values (3,'Andrei Ardelean')
insert into HospitalName(Id,HospitalName) values (4,'Octavian Iosif')
insert into HospitalName(Id,HospitalName) values (5,'Avram Iancu')


delete from HospitalSize
select * from HospitalSize
declare @randomNumber int = 0
set @randomNumber = floor(rand()*(100-1)+1)
declare @start int = 0
declare @end int = 10
while @start < @end 
begin 
	insert into HospitalSize(Id,Size) values (@start,@randomNumber)
	declare @randomCollector int = 0
	set @randomCollector = floor(rand()*(100-1)+1)
	set @randomNumber = @randomNumber + @randomCollector
	set @start = @start + 1
end

drop procedure populateHospital
go
create procedure populateHospital(@current int)
as
	declare @HospitalName nvarchar(max)
	declare @Xml xml = (select H.HospitalName from HospitalName H where H.Id = floor(rand()*(5-1)+1))
	select @HospitalName = cast(@Xml.query('string(.)') as nvarchar(max))
	declare @HospitalSize int = 0
	set @HospitalSize = (select H.Size from HospitalSize H where H.Id = @current)
	insert into Hospital(HospitalId,HospitalName,HospitalSize)
	values (@current,@HospitalName,@HospitalSize)
go

declare @currentIndex int = 1
declare @resultIndex int = 10
while @currentIndex  < @resultIndex
begin
	exec populateHospital @current = @currentIndex
	set @currentIndex = @currentIndex + 1
end

select * from Hospital 
delete from Hospital 

create table DoctorName(
	Id int not null,
	Name varchar(255)
)

insert into DoctorName(Id,Name) values(1,'Andrei'),
		(2,'Tudor'),
		(3,'Mihai'),
		(4,'Alexandru'),
		(5,'Aurel')

create table DoctorPatientNumber(
	Id int not null primary key,
	Number int not null
)

declare @randomNumber int = 0
set @randomNumber = floor(rand()*(100-1)+1)
declare @start int = 0
declare @end int = 10
while @start < @end 
begin 
	insert into DoctorPatientNumber(Id,Number) values (@start,@randomNumber)
	declare @randomCollector int = 0
	set @randomCollector = floor(rand()*(100-1)+1)
	set @randomNumber = @randomNumber + @randomCollector
	set @start = @start + 1
end

select *from DoctorPatientNumber
select * from Doctors

drop procedure populateDoctor
go
create procedure populateDoctor(@current int)
as
	declare @DoctorName nvarchar(max)
	declare @Xml xml = (select D.Name  from DoctorName D where D.Id = floor(rand()*(5-1)+1))
	select @DoctorName = cast(@Xml.query('string(.)') as nvarchar(max))
	declare @DoctorPatientNumber int = 0
	set @DoctorPatientNumber = (select D.Number from DoctorPatientNumber D where D.Id = @current)
	insert into Doctors(DoctorId,DoctorName,DoctorPatientNumber) values (@current,@DoctorName,@DoctorPatientNumber)
go

declare @currentIndex int = 0
declare @end int = 10
while @currentIndex < @end 
begin
	exec populateDoctor @current = @currentIndex
	set @currentIndex = @currentIndex + 1
end

select * from Doctors 
delete from Doctors 
drop table DoctorId
create table DoctorId(
	Row int not null primary key,
	Id int not null identity(1,1)
)

drop table HospitalId
create table HospitalId(
	Row int not null primary key,
	Id int not null identity(1,1)
)	

insert into DoctorId
select D.DoctorId  from Doctors D

insert into HospitalId
select H.HospitalId from Hospital H

select * from DoctorId
select * from HospitalId

go
create procedure populateWorkplace(@current int)
as	
	declare @doctorid int = 0
	declare @hospitalid int =0
	set @doctorid = (select D.Id from DoctorId D where D.Row =  floor(rand()*(5-1)+1))
	set @hospitalid = (select H.Id from HospitalId H where H.Row =  floor(rand()*(5-1)+1))
	insert into WorkPlace(WorkPlaceId,DoctorId,HospitalId) values (@current,@doctorid,@hospitalid)
go

declare @currentIndex int = 0
declare @endIndex int = 5
while @currentIndex < @endIndex
begin
	exec populateWorkplace @current = @currentIndex
	set @currentIndex = @currentIndex + 1
end

select * from WorkPlace
select * from Doctors
select * from Hospital

--clustered index scan
select * 
from Hospital H
where  H.HospitalName = 'Constantin Opris' 

--clustered index seek
select * 
from Hospital H
where H.HospitalSize between 100 and 150

--nonclustered index scan
select H.HospitalId
from Hospital H

--nonclustered index seek
select H.HospitalId
from Hospital H
where H.HospitalSize between 1 and 110

--key lookup
select H.HospitalName
from Hospital H
where H.HospitalId = 2

--we create the index over the where clause

select D.DoctorName
from Doctors D
where D.DoctorPatientNumber = 10

drop index if exists Doctors.DoctorIndex
go
create nonclustered Index DoctorIndex
on Doctors(DoctorPatientNumber asc)

select D.DoctorName
from Doctors D
where D.DoctorPatientNumber = 10


--create the view over WorkPlace and Doctor Table


drop view CrossView
go
create or alter view CrossView
as
	select W.HospitalId,D.DoctorPatientNumber
	from Doctors D inner join WorkPlace W
	on D.DoctorId = W.DoctorId 
	where W.WorkPlaceId > 2
go
select * from WorkPlace
select * from Doctors
select * from CrossView

drop index if exists WorkPlace.CrossIndex
create nonclustered index CrossIndex on WorkPlace(WorkPlaceId) include (DoctorId)

select * from CrossView