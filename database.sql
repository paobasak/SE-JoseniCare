CREATE DATABASE if NOT EXISTS josenicare_db;
USE josenicare_db;

SELECT * FROM appointments;

CREATE TABLE if NOT EXISTS appointments(
    id INT PRIMARY KEY AUTO_INCREMENT,
    campus VARCHAR(255) NOT NULL,
    type VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE appointments ADD COLUMN purpose VARCHAR(255) NOT NULL;
ALTER TABLE appointments ADD COLUMN status varchar(255)	not null;
ALTER TABLE appointments ADD COLUMN schedule date;
ALTER TABLE appointments MODIFY COLUMN schedule DATETIME;

CREATE table if not exists healthSurvey(
surveyId INT PRIMARY KEY auto_increment,
healthRating Integer not null,
areaAffected VARCHAR(255) not null,
symptoms NVARCHAR(500) not null,
symptom_start_date DATE,
painScale INT,
pain_location varchar(255),
medication_taken BOOLEAN 
);
