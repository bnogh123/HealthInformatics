-- =====================================================================
-- Fitbit (Kaggle arashnic/fitbit)
-- Collection tracking: every fact table carries `session_id` (NOT NULL, FK) into
-- CollectionSession, which holds date_collected_start / date_collected_end once
-- per collection run instead of repeating them on every row.
-- Column names match the CSV headers so LOAD DATA / to_sql maps 1:1.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS fitbit
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_0900_ai_ci;
USE fitbit;

DROP TABLE IF EXISTS SleepDay;
DROP TABLE IF EXISTS DailySteps;
DROP TABLE IF EXISTS DailyIntensities;
DROP TABLE IF EXISTS DailyCalories;
DROP TABLE IF EXISTS WeightLogInfo;
DROP TABLE IF EXISTS MinuteSleep;
DROP TABLE IF EXISTS MinuteStepsNarrow;
DROP TABLE IF EXISTS MinuteMETsNarrow;
DROP TABLE IF EXISTS MinuteIntensitiesNarrow;
DROP TABLE IF EXISTS MinuteCaloriesNarrow;
DROP TABLE IF EXISTS HourlySteps;
DROP TABLE IF EXISTS HourlyIntensities;
DROP TABLE IF EXISTS HourlyCalories;
DROP TABLE IF EXISTS HeartrateSeconds;
DROP TABLE IF EXISTS DailyActivity;
DROP TABLE IF EXISTS Participant;
DROP TABLE IF EXISTS CollectionSession;

-- ---------------------------------------------------------------------
-- Collection sessions (one row per collection window)
-- ---------------------------------------------------------------------
CREATE TABLE CollectionSession (
    session_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    date_collected_start DATETIME NOT NULL,
    date_collected_end DATETIME NOT NULL,
    PRIMARY KEY (session_id),
    UNIQUE KEY uq_session_window (date_collected_start, date_collected_end),
    CONSTRAINT chk_session_window CHECK (date_collected_end >= date_collected_start)
) 
ENGINE=InnoDB;

-- Seed: windows observed in the two folder
-- REPLACE IF SESSION DATES ARE DIFFERENT IN THE ORIGINAL DATA
--   session 1: first folder  (data 2016-03-12 .. 2016-04-12)
--   session 2: second folder (data 2016-04-12 .. 2016-05-12)
INSERT INTO CollectionSession (session_id, date_collected_start, date_collected_end)
VALUES (1, '2016-03-12 00:00:00', '2016-04-12 23:59:59'),
       (2, '2016-04-12 00:00:00', '2016-05-12 23:59:59');

-- ---------------------------------------------------------------------
-- Participant (the `Id` shared by every file; parent for all FKs)
-- Populate from SELECT DISTINCT Id across the files (all Ids appear in dailyActivity)
-- ---------------------------------------------------------------------
CREATE TABLE Participant (
    Id BIGINT UNSIGNED NOT NULL, 
    PRIMARY KEY (Id)
) 
ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- dailyActivity_merged.csv   (grain: Id + ActivityDate)
-- ---------------------------------------------------------------------
CREATE TABLE DailyActivity (
    Id BIGINT UNSIGNED NOT NULL,
    ActivityDate DATE NOT NULL,
    TotalSteps INT UNSIGNED NOT NULL,
    TotalDistance DOUBLE NOT NULL,
    TrackerDistance DOUBLE NOT NULL,
    LoggedActivitiesDistance DOUBLE NOT NULL,
    VeryActiveDistance DOUBLE NOT NULL,
    ModeratelyActiveDistance DOUBLE NOT NULL,
    LightActiveDistance DOUBLE NOT NULL,
    SedentaryActiveDistance DOUBLE NOT NULL,
    VeryActiveMinutes SMALLINT UNSIGNED NOT NULL,
    FairlyActiveMinutes SMALLINT UNSIGNED NOT NULL,
    LightlyActiveMinutes SMALLINT UNSIGNED NOT NULL,
    SedentaryMinutes SMALLINT UNSIGNED NOT NULL,
    Calories INT UNSIGNED NOT NULL,
    session_id TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id, ActivityDate, session_id),
    CONSTRAINT fk_da_participant FOREIGN KEY (Id) REFERENCES Participant (Id),
    CONSTRAINT fk_da_session FOREIGN KEY (session_id) REFERENCES CollectionSession (session_id)
) 
ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- dailyCalories_merged.csv   (grain: Id + ActivityDay; folder 2 only)
-- dailyIntensities_merged.csv, dailySteps_merged.csv: same grain and source.
-- Their values duplicate DailyActivity columns (all 940 rows matched in folder 2).
-- ---------------------------------------------------------------------
CREATE TABLE DailyCalories (
    Id BIGINT UNSIGNED NOT NULL,
    ActivityDay DATE NOT NULL,
    Calories INT UNSIGNED NOT NULL,
    session_id TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id, ActivityDay, session_id),
    CONSTRAINT fk_dcal_participant FOREIGN KEY (Id) REFERENCES Participant (Id),
    CONSTRAINT fk_dcal_session FOREIGN KEY (session_id) REFERENCES CollectionSession (session_id)
) 
ENGINE=InnoDB;

CREATE TABLE DailyIntensities (
    Id BIGINT UNSIGNED NOT NULL,
    ActivityDay DATE NOT NULL,
    SedentaryMinutes SMALLINT UNSIGNED NOT NULL,
    LightlyActiveMinutes SMALLINT UNSIGNED NOT NULL,
    FairlyActiveMinutes SMALLINT UNSIGNED NOT NULL,
    VeryActiveMinutes SMALLINT UNSIGNED NOT NULL,
    SedentaryActiveDistance DOUBLE NOT NULL,
    LightActiveDistance DOUBLE NOT NULL,
    ModeratelyActiveDistance DOUBLE NOT NULL,
    VeryActiveDistance DOUBLE NOT NULL,
    session_id TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id, ActivityDay, session_id),
    CONSTRAINT fk_dint_participant FOREIGN KEY (Id) REFERENCES Participant (Id),
    CONSTRAINT fk_dint_session FOREIGN KEY (session_id) REFERENCES CollectionSession (session_id)
) 
ENGINE=InnoDB;

CREATE TABLE DailySteps (
    Id BIGINT UNSIGNED NOT NULL,
    ActivityDay DATE NOT NULL,
    StepTotal INT UNSIGNED NOT NULL,
    session_id TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id, ActivityDay, session_id),
    CONSTRAINT fk_dst_participant FOREIGN KEY (Id) REFERENCES Participant (Id),
    CONSTRAINT fk_dst_session FOREIGN KEY (session_id) REFERENCES CollectionSession (session_id)
) 
ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- heartrate_seconds_merged.csv   (grain: Id + Time, 5-second readings)
-- ---------------------------------------------------------------------
CREATE TABLE HeartrateSeconds (
    Id BIGINT UNSIGNED NOT NULL,
    `Time` DATETIME NOT NULL,
    BPM SMALLINT UNSIGNED NOT NULL,
    session_id TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id, `Time`, session_id),
    CONSTRAINT fk_hr_participant FOREIGN KEY (Id) REFERENCES Participant (Id),
    CONSTRAINT fk_hr_session FOREIGN KEY (session_id) REFERENCES CollectionSession (session_id)
) 
ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- hourly tables   (grain: Id + ActivityHour)
-- ---------------------------------------------------------------------
CREATE TABLE HourlyCalories (
    Id BIGINT UNSIGNED NOT NULL,
    ActivityHour DATETIME NOT NULL,
    Calories INT UNSIGNED NOT NULL,
    session_id TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id, ActivityHour, session_id),
    CONSTRAINT fk_hc_participant FOREIGN KEY (Id) REFERENCES Participant (Id),
    CONSTRAINT fk_hc_session FOREIGN KEY (session_id) REFERENCES CollectionSession (session_id)
) 
ENGINE=InnoDB;

CREATE TABLE HourlyIntensities (
    Id BIGINT UNSIGNED NOT NULL,
    ActivityHour DATETIME NOT NULL,
    TotalIntensity INT UNSIGNED NOT NULL,
    AverageIntensity DOUBLE NOT NULL,
    session_id TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id, ActivityHour, session_id),
    CONSTRAINT fk_hi_participant FOREIGN KEY (Id) REFERENCES Participant (Id),
    CONSTRAINT fk_hi_session FOREIGN KEY (session_id) REFERENCES CollectionSession (session_id)
) 
ENGINE=InnoDB;

CREATE TABLE HourlySteps (
    Id BIGINT UNSIGNED NOT NULL,
    ActivityHour DATETIME NOT NULL,
    StepTotal INT UNSIGNED NOT NULL,
    session_id TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id, ActivityHour, session_id),
    CONSTRAINT fk_hs_participant FOREIGN KEY (Id) REFERENCES Participant (Id),
    CONSTRAINT fk_hs_session FOREIGN KEY (session_id) REFERENCES CollectionSession (session_id)
) 
ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- minute "narrow" tables   (grain: Id + ActivityMinute)
-- ---------------------------------------------------------------------
CREATE TABLE MinuteCaloriesNarrow (
    Id BIGINT UNSIGNED NOT NULL,
    ActivityMinute DATETIME NOT NULL,
    Calories DOUBLE NOT NULL,
    session_id TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id, ActivityMinute, session_id),
    CONSTRAINT fk_mc_participant FOREIGN KEY (Id) REFERENCES Participant (Id),
    CONSTRAINT fk_mc_session FOREIGN KEY (session_id) REFERENCES CollectionSession (session_id)
) 
ENGINE=InnoDB;

CREATE TABLE MinuteIntensitiesNarrow (
    Id BIGINT UNSIGNED NOT NULL,
    ActivityMinute DATETIME NOT NULL,
    Intensity TINYINT UNSIGNED NOT NULL, -- 0-3
    session_id TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id, ActivityMinute, session_id),
    CONSTRAINT fk_mi_participant FOREIGN KEY (Id) REFERENCES Participant (Id),
    CONSTRAINT fk_mi_session FOREIGN KEY (session_id) REFERENCES CollectionSession (session_id)
) 
ENGINE=InnoDB;

CREATE TABLE MinuteMETsNarrow (
    Id BIGINT UNSIGNED NOT NULL,
    ActivityMinute DATETIME NOT NULL,
    METs SMALLINT UNSIGNED NOT NULL, -- Fitbit stores METs x10
    session_id TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id, ActivityMinute, session_id),
    CONSTRAINT fk_mm_participant FOREIGN KEY (Id) REFERENCES Participant (Id),
    CONSTRAINT fk_mm_session FOREIGN KEY (session_id) REFERENCES CollectionSession (session_id)
) 
ENGINE=InnoDB;

CREATE TABLE MinuteStepsNarrow (
    Id BIGINT UNSIGNED NOT NULL,
    ActivityMinute DATETIME NOT NULL,
    Steps SMALLINT UNSIGNED NOT NULL,
    session_id TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id, ActivityMinute, session_id),
    CONSTRAINT fk_ms_participant FOREIGN KEY (Id) REFERENCES Participant (Id),
    CONSTRAINT fk_ms_session FOREIGN KEY (session_id) REFERENCES CollectionSession (session_id)
) 
ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- minuteSleep_merged.csv   (grain: Id + date)
-- NOTE: the source files contain exact duplicate rows (525 in folder 1, 543 in
--       folder 2); de-duplicate (drop_duplicates) before loading or the PK will
--       reject them. Rows overlapping between folders are identical.
-- value: 1 = asleep, 2 = restless, 3 = awake
-- ---------------------------------------------------------------------
CREATE TABLE MinuteSleep (
    Id BIGINT UNSIGNED NOT NULL,
    `date` DATETIME NOT NULL,
    `value` TINYINT UNSIGNED NOT NULL,
    logId BIGINT UNSIGNED NOT NULL,
    session_id TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id, `date`, session_id),
    KEY idx_sleep_logId (logId),
    CONSTRAINT fk_sl_participant FOREIGN KEY (Id) REFERENCES Participant (Id),
    CONSTRAINT fk_sl_session FOREIGN KEY (session_id) REFERENCES CollectionSession (session_id)
) 
ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- weightLogInfo_merged.csv   (grain: Id + LogId)
-- LogId alone is NOT unique (it is a ms timestamp shared across users),
-- so the PK is (Id, LogId, session_id). Fat is NULL for 31 of 33 rows.
-- ---------------------------------------------------------------------
CREATE TABLE WeightLogInfo (
    Id BIGINT UNSIGNED NOT NULL,
    `Date` DATETIME NOT NULL,
    WeightKg DOUBLE NOT NULL,
    WeightPounds DOUBLE NOT NULL,
    Fat DOUBLE NULL,
    BMI DOUBLE NOT NULL,
    IsManualReport BOOLEAN NOT NULL, -- CSV has 'True'/'False' text; convert to 1/0
    LogId BIGINT UNSIGNED NOT NULL,
    session_id TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id, LogId, session_id),
    UNIQUE KEY uq_weight_id_date (Id, `Date`, session_id),
    CONSTRAINT fk_wt_participant FOREIGN KEY (Id) REFERENCES Participant (Id),
    CONSTRAINT fk_wt_session FOREIGN KEY (session_id) REFERENCES CollectionSession (session_id)
) 
ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- sleepDay_merged.csv   (grain: Id + SleepDay; second folder only)
-- The source has 3 exact duplicate rows: drop them.
-- SleepDay is always 12:00:00 AM in the file, so it is stored as a DATE.
-- ---------------------------------------------------------------------
CREATE TABLE SleepDay (
    Id BIGINT UNSIGNED NOT NULL,
    SleepDay DATE NOT NULL,
    TotalSleepRecords TINYINT UNSIGNED NOT NULL,
    TotalMinutesAsleep SMALLINT UNSIGNED NOT NULL,
    TotalTimeInBed SMALLINT UNSIGNED NOT NULL,
    session_id TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id, SleepDay, session_id),
    CONSTRAINT fk_sd_participant FOREIGN KEY (Id) REFERENCES Participant (Id),
    CONSTRAINT fk_sd_session FOREIGN KEY (session_id) REFERENCES CollectionSession (session_id)
) 
ENGINE=InnoDB;