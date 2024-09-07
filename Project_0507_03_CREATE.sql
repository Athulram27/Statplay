USE BUDT703_Project_0507_03

DROP TABLE IF EXISTS Locate
DROP TABLE IF EXISTS Match
DROP TABLE IF EXISTS Stadium
DROP TABLE IF EXISTS Score
DROP TABLE IF EXISTS Opponent
DROP TABLE IF EXISTS Calendar
DROP TABLE IF EXISTS Coach

-- Create table Coach
CREATE TABLE Coach (
    coachId CHAR(3) NOT NULL,
	coachLastName VARCHAR(50),
    coachFirstName VARCHAR(50),
    coachExp INT,
    coachStartDt DATE,
    coachEndDt DATE,
	CONSTRAINT pk_Coach_coachId PRIMARY KEY(coachId)
);

-- Create table Calendar
CREATE TABLE Calendar (
    calYear CHAR(4) NOT NULL,
    calMonth CHAR(2) NOT NULL,
    coachId CHAR(3),
	CONSTRAINT pk_Calendar_calYear_calMonth PRIMARY KEY(calYear, calMonth),
	CONSTRAINT fk_Calendar_coachId FOREIGN KEY (coachId)
		REFERENCES Coach (coachId)
		ON DELETE SET NULL
		ON UPDATE CASCADE
);

-- Create table Opponent
CREATE TABLE Opponent (
    oppId CHAR(4) NOT NULL,
    oppName VARCHAR(50),
    oppCity VARCHAR(50),
    oppState VARCHAR(50),
    oppCountry VARCHAR(10)
	CONSTRAINT pk_Opponent_oppId PRIMARY KEY(oppId)
);

-- Create table Score
CREATE TABLE Score (
    scoreId CHAR(10) NOT NULL,
    scoreMd INT,
    scoreOpp INT
	CONSTRAINT pk_Score_scoreId PRIMARY KEY(scoreId)

);

-- Create table Stadium
CREATE TABLE Stadium (
    stdId CHAR(4) NOT NULL,
    stdCity VARCHAR(50),
    stdState VARCHAR(50),
    stdCountry VARCHAR(50),
	CONSTRAINT pk_Stadium_stdId PRIMARY KEY(stdId)
);

-- Create table Match
CREATE TABLE Match (
    scoreId CHAR(10) NOT NULL,
    calYear CHAR(4),
    calMonth CHAR(2),
    oppId CHAR(4),
    matchVenueType VARCHAR(50),
	CONSTRAINT pk_Match_scoreId PRIMARY KEY(scoreId),
	CONSTRAINT fk_Match_scoreId FOREIGN KEY (scoreId)
		REFERENCES Score (scoreId)
		ON DELETE NO ACTION
		ON UPDATE CASCADE,
	CONSTRAINT fk_calYear_calMonth FOREIGN KEY (calYear, calMonth)
		REFERENCES Calendar (calYear, calMonth)
		ON DELETE NO ACTION
		ON UPDATE CASCADE,
	CONSTRAINT fk_Match_oppId FOREIGN KEY (oppId)
		REFERENCES Opponent (oppId)
		ON DELETE CASCADE
		ON UPDATE CASCADE    
);

-- Create table Locate
CREATE TABLE Locate (
    scoreId CHAR(10),
	oppId CHAR(4),
    stdId CHAR(4),
	CONSTRAINT pk_Locate_scoreId PRIMARY KEY(scoreId),
    CONSTRAINT fk_Locate_scoreId FOREIGN KEY (scoreId)
		REFERENCES Score (scoreId)
		ON DELETE NO ACTION
		ON UPDATE CASCADE,
	CONSTRAINT fk_Locate_oppId FOREIGN KEY (oppId)
		REFERENCES Opponent (oppId)
		ON DELETE NO ACTION
		ON UPDATE CASCADE,
	CONSTRAINT fk_Locate_std FOREIGN KEY (stdId)
		REFERENCES Stadium (stdId)
		ON DELETE NO ACTION
		ON UPDATE CASCADE    
);

