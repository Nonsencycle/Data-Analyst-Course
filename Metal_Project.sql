--Metal_DB by Shmulik Pfeifel


go

USE [master]
GO

IF EXISTS
	(SELECT * FROM SYSDATABASES WHERE NAME = 'Metal_DB')
		
	BEGIN
		ALTER DATABASE [Metal_DB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE [Metal_DB];
	END
GO


CREATE DATABASE [Metal_DB]
 
 GO

USE Metal_DB

GO

--This database contains informaton about Scandinavian Death Metal bands,
-- mostly from the 90s. The database contains information about 20 seminal black metal bands and their band members.
--It shows the musicians in each band, the period that they were in the band, and what instrument 
--they played during that time.
--These features could be used to demonstrate the flow of musicians within the very intimate
--and fluid scandinavian metal scene of the early 90s from one project to another (people
--often played in several bands with other people from other bands) ,and to note their talent 
--in playing multiple instruments
--The table is ready for additional bands/musicians/music types to be added.
GO

Create Table Country --this table lists the countries of bands and musicians
(Country_ID int IDENTITY (1,1) CONSTRAINT Country_ID_pk PRIMARY KEY
,Country_Name VARCHAR (25))

Create Table Instrument --this table lists musical instruments played by musicians
(Instrument_ID int IDENTITY (1,1) Constraint Instrument_ID_pk PRIMARY KEY
,Instrument_name VARCHAR (20),
)

Create Table Musician --This table provides details about musicians (with a unique musician name identifier)
--their country of origin, and if the musician is still alive (which is certainly a relevant question in music)
(Musician_ID int IDENTITY (1,1) Constraint Musician_ID_PK PRIMARY KEY
,MusicianName varchar(50) CONSTRAINT MusicianName_UK UNIQUE
,Country_ID int CONSTRAINT Country_ID_fk FOREIGN KEY references Country(Country_ID)
,IsAlive bit
)

Create Table MetalType --This table describes the music type, currently only Black Metal
(MetalType_ID int IDENTITY (1,1) Constraint MetalType_ID_PK PRIMARY KEY
,MetalType varchar(25)
)

Create Table [Label] -- This table provides the music labels that each band works with
([Label_ID] int IDENTITY (1,1) Constraint Label_ID_PK PRIMARY KEY
,LabelName varchar(25)
,LabelCountry int CONSTRAINT LabelCountry_fk FOREIGN KEY REFERENCES Country(Country_ID)
)
Create Table Band -- this table describes the band, when is was formed and when it disbanded, its label and the music type
--that it plays, and if the band is still active
(Band_ID int IDENTITY (1,1) Constraint Band_ID_PK PRIMARY KEY
,BandName varchar (25) NOT NULL
,StartDate DATE
,EndDate DATE 
,[Label_ID] int CONSTRAINT Label_id_fk FOREIGN KEY references [Label]([Label_ID])
,MetalType_id int CONSTRAINT MetalType_ID_fk FOREIGN KEY references [MetalType]([MetalType_ID])
,IsActive bit
)

Create Table YearsInBand --This table links between the musicians table and the band table so that potentially a musician 
--may be referenced for being in more than one band and vice versa, a band will be linked to more than one musician
(Musician_ID int CONSTRAINT Musician_ID_YearsInBand_fk FOREIGN KEY REFERENCES Musician(Musician_ID)
,Band_ID int CONSTRAINT Band_ID_fk FOREIGN KEY REFERENCES Band(Band_ID)
,CONSTRAINT YearsInBand_PK PRIMARY KEY (Musician_ID, Band_ID)
,Joined DATE
,[Left] DATE)

CREATE Table MusicianPlaysInstrument -- This table links between musicians and instruments so potentially
-- a musician may play more than one instrument and an instrument will be linked to more than one musician
(Musician_ID int CONSTRAINT Musician_ID_MusicianPlaysInstrument_fk FOREIGN KEY REFERENCES Musician(Musician_ID)
,Instrument_ID int CONSTRAINT Instrument_ID_fk FOREIGN KEY REFERENCES Instrument(Instrument_ID)
, CONSTRAINT MusicianPlaysInstrument_PK PRIMARY KEY (Musician_ID, Instrument_ID))

GO

INSERT INTO MetalType (MetalType) --Metal type
    VALUES
	('Black Metal');

INSERT INTO Country (Country_Name) --List of relevant countries
	VALUES
	('Norway'),
	('Poland'),
	('Sweden'),
	('Hungary');

INSERT INTO [Label] (LabelName) --List of relevant labels
	VALUES
	('Nuclear Blast'),
	('Century Media'),
	('Season of Mist');

INSERT INTO Instrument (Instrument_name) --List of relevant instruments
	VALUES
	('Guitar'),
	('Vocals'),
	('Drums'),
	('Keyboards'),
	('Bass');

INSERT INTO Band (BandName, StartDate, EndDate, [Label_ID], MetalType_id, IsActive) --A collection of columns describing
--a band
VALUES
    ('Mayhem', '1984-01-01', NULL, 1, 1, 1),    -- Nuclear Blast, Black Metal, still active
    ('Darkthrone', '1986-01-01', NULL, 2, 1, 1), -- Century Media, Black Metal, still active
    ('Emperor', '1991-01-01', NULL, 3, 1, 1),   -- Season of Mist, Black Metal, still active
    ('Immortal', '1991-01-01', NULL, 1, 1, 1),  -- Nuclear Blast, Black Metal, still active
    ('Satyricon', '1991-01-01', NULL, 2, 1, 1), -- Century Media, Black Metal, still active
    ('Enslaved', '1991-01-01', NULL, 3, 1, 1),  -- Season of Mist, Black Metal, still active
    ('Marduk', '1990-01-01', NULL, 1, 1, 1),    -- Nuclear Blast, Black Metal, still active
    ('Dimmu Borgir', '1993-01-01', NULL, 2, 1, 1),  -- Century Media, Black Metal, still active
    ('Bathory', '1983-01-01', '2004-01-01', 3, 1, 0),  -- Season of Mist, Black Metal, disbanded
    ('Gorgoroth', '1992-01-01', NULL, 1, 1, 1),  -- Nuclear Blast, Black Metal, still active
    ('Burzum', '1991-01-01', NULL, 2, 1, 1),    -- Century Media, Black Metal, still active
    ('Watain', '1998-01-01', NULL, 3, 1, 1),    -- Season of Mist, Black Metal, still active
    ('Dark Funeral', '1993-01-01', NULL, 1, 1, 1),  -- Nuclear Blast, Black Metal, still active
    ('Dissection', '1989-01-01', '2006-01-01', 2, 1, 0),  -- Century Media, Black Metal, disbanded
    ('Mayhem', '1984-01-01', NULL, 1, 1, 1),    -- Nuclear Blast, Black Metal, still active
    ('1349', '1997-01-01', NULL, 2, 1, 1),      -- Century Media, Black Metal, still active
    ('Taake', '1993-01-01', NULL, 3, 1, 1),     -- Season of Mist, Black Metal, still active
    ('Tsjuder', '1993-01-01', NULL, 1, 1, 1),   -- Nuclear Blast, Black Metal, still active
    ('Carpathian Forest', '1992-01-01', NULL, 2, 1, 1),  -- Century Media, Black Metal, still active
    ('Keep of Kalessin', '1993-01-01', NULL, 3, 1, 1);  -- Season of Mist, Black Metal, still active

INSERT INTO Musician (MusicianName, Country_ID, IsAlive)  --A collection of columns describing
--a musician
VALUES
    ('Euronymous', 1, 0),  -- Norway, deceased
    ('Abbath Doom Occulta', 1, 1),  -- Norway, still alive
    ('Fenriz', 1, 1),  -- Norway, still alive
    ('Ihsahn', 1, 1),  -- Norway, still alive
    ('Nocturno Culto', 1, 1),  -- Norway, still alive
    ('Gaahl', 1, 1),  -- Norway, still alive
    ('Varg Vikernes', 1, 1),  -- Norway, still alive
    ('Nergal', 2, 1),  -- Poland, still alive
    ('Shagrath', 3, 1),  -- Sweden, still alive
    ('Jon Noedtveidt', 1, 0),  -- Norway, deceased
    ('Frost', 1, 1),  -- Norway, still alive
    ('Attila Csihar', 4, 1),  -- Hungary, still alive
    ('Necrobutcher', 1, 1),  -- Norway, still alive
    ('Ghaal', 1, 1),  -- Norway, still alive
    ('Mortiis', 1, 1),  -- Norway, still alive
    ('Grutle Kjellson', 1, 1),  -- Norway, still alive
    ('Maniac', 1, 1),  -- Norway, still alive
    ('Nagash', 3, 1),  -- Sweden, still alive
    ('Daemonaz', 1, 1),  -- Norway, still alive
	('Hellhammer', 1, 1);  -- Norway, still alive

INSERT INTO MusicianPlaysInstrument (Musician_ID, Instrument_ID) --A table connecting musicians and their instruments
VALUES
    -- Euronymous - Guitar
    (1, 1),
    
    -- Abbath Doom Occulta - Guitar, Vocals
    (2, 1),
    (2, 2),
    
    -- Fenriz - Drums, Vocals
    (3, 3),
    (3, 2),
    
    -- Ihsahn - Guitar, Keyboards, Vocals
    (4, 1),
    (4, 4),
    (4, 2),
    
    -- Nocturno Culto - Guitar, Vocals
    (5, 1),
    (5, 2),
    
    -- Gaahl - Vocals
    (6, 2),
    
    -- Varg Vikernes - Guitar, Bass, Keyboards, Vocals
    (7, 1),
    (7, 5),
    (7, 4),
    (7, 2),
    
    -- Nergal - Guitar, Vocals
    (8, 1),
    (8, 2),
    
    -- Shagrath - Vocals
    (9,2),
    
    -- Jon Noedtveidt - Guitar, Vocals
    (10, 1),
    (10, 2),
    
    -- Frost - Drums
    (11, 3),
    
    -- Attila Csihar - Vocals
    (12, 2),
    
    -- Necrobutcher - Bass
    (13, 5),
    
    -- Ghaal - Vocals
    (14, 2),
    
    -- Mortiis - Keyboards, Vocals
    (15, 4),
    (15, 2),
    
    -- Grutle Kjellson - Bass, Vocals
    (16, 5),
    (16, 2),
    
    -- Maniac - Vocals
    (17, 2),
    
    -- Nagash - Bass, Vocals
    (18, 5),
    (18, 2),
    
    -- Daemonaz - Guitar, Vocals
    (19, 1),
    (19, 2),
    
    -- Hellhammer - Drums
    (20, 3);


-- Euronymous (Mayhem)
INSERT INTO YearsInBand (Musician_ID, Band_ID, Joined, [Left])  --A collection of columns describing
--a how many years each musician was in each of their bands
VALUES (1, 2, '1984-01-01', '1993-08-10'),  -- Mayhem

-- Abbath Doom Occulta (Immortal)
	(2, 5, '1990-01-01', NULL),  -- Immortal (No left date)

-- Fenriz (Darkthrone)
	(3, 3, '1986-01-01', NULL),  -- Darkthrone (No left date)

-- Ihsahn (Emperor)
	(4, 4, '1991-01-01', '2001-04-16'),  -- Emperor

-- Nocturno Culto (Darkthrone)
	(5, 3, '1988-01-01', NULL),  -- Darkthrone (No left date)

-- Gaahl (Gorgoroth)
	(6, 11, '1998-01-01', '2007-12-12'),  -- Gorgoroth

-- Varg Vikernes (Burzum)
	(7, 12, '1991-01-01', '1993-08-10'),  -- Burzum

-- Nergal (Behemoth)
	(8, 7, '1991-01-01', NULL),  -- Behemoth (No left date)

-- Shagrath (Dimmu Borgir)
	(9, 9, '1993-01-01', NULL),  -- Dimmu Borgir (No left date)

-- Jon Noedtveidt (Dissection)
	(10, 15, '1989-01-01', '2006-08-16'),  -- Dissection

-- Frost (Satyricon, 1349)
    (11, 6, '1993-01-01', '2009-06-05'),  -- Satyricon
    (11, 17, '1998-01-01', NULL),  -- 1349 (No left date)

-- Attila Csihar (Mayhem)
	(12, 16, '1994-01-01', NULL),  -- Mayhem (No left date)

-- Necrobutcher (Mayhem)
	(13, 2, '1984-01-01', '1993-08-10'),  -- Mayhem

-- Ghaal (Gorgoroth)
	(14, 11, '1998-01-01', '2007-12-12'),  -- Gorgoroth

-- Mortiis (Emperor)
	(15, 4, '1991-01-01', '2001-04-16'),  -- Emperor

-- Grutle Kjellson (Enslaved)
	(16, 7, '1991-01-01', NULL),  -- Enslaved (No left date)

-- Maniac (Mayhem)
	(17, 16, '1986-01-01', '2005-01-01'),  -- Mayhem

-- Nagash (Dimmu Borgir)
	(18, 9, '1993-01-01', NULL),  -- Dimmu Borgir (No left date)

-- Daemonaz (Immortal)
	(19, 5, '1991-01-01', NULL),  -- Immortal (No left date)

-- Hellhammer (Mayhem)
	(20, 16, '1988-01-01', '1993-08-10');  -- Mayhem
	
