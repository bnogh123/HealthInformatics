/***********************************************
** File:   Team 7 DDL File
** Desc:   Creating the Dimensional Model
** Auth:   
** Date:   11/18/2026
************************************************/

-- -----------------------------------------------------
-- base schema 
-- -----------------------------------------------------

CREATE SCHEMA IF NOT EXISTS `fitbit` DEFAULT CHARACTER SET latin1;
USE `fitbit`;

-- -----------------------------------------------------
-- Table `fitbit`.`daily_activity` -- merge s1 and s2 data
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS `fitbit`.`daily_activity`(
    `id` INT(10) NOT NULL,
    `ActivityDate` DATETIME NOT NULL,
    `TotalSteps` INT(10) DEFAULT NULL,
    `TrackerDistance` FLOAT(10) DEFAULT NULL,
    `LoggedActivitiesDistance` FLOAT(10) DEFAULT NULL,
    `VeryActiveDistance` FLOAT(10) DEFAULT NULL,
    `ModeratelyActiveDistance` FLOAT(10) DEFAULT NULL,
    `LightActiveDistance` FLOAT(10) DEFAULT NULL,
    `SedentaryActiveDistance` FLOAT(10) DEFAULT NULL,
    `VeryActiveMinutes` INT(10) DEFAULT NULL,
    `FairlyActiveMinutes` INT(10) DEFAULT NULL,
    `LightlyActiveMinutes` INT(10) DEFAULT NULL,
    `SedentaryMinutes` INT(10) DEFAULT NULL,
    `Calories` INT(10) DEFAULT NULL,
    `date_collected_start`, DATETIME NOT NULL,
    `date_collected_end` DATETIME NOT NULL,
    PRIMARY KEY (`id`)
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;