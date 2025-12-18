-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Dec 07, 2025 at 12:16 PM
-- Server version: 9.4.0
-- PHP Version: 8.5.0
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";
USE josenicare_db;
SELECT * FROM `users`;

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `josenicare_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `appointments`
--
CREATE TABLE `appointments` (
  `id` int NOT NULL,
  `user_id` int DEFAULT NULL COMMENT 'Patient user ID',
  `date` date NOT NULL,
  `time` time NOT NULL,
  `purpose` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `campus` enum('Main','Basak') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Main',
  `type` enum('Dental','Check-up') COLLATE utf8mb4_unicode_ci NOT NULL,
  `doctor` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('Pending','Confirmed','Cancelled','Completed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pending',
  `doctor_note` text COLLATE utf8mb4_unicode_ci,
  `medication` text COLLATE utf8mb4_unicode_ci,
  `cancellation_note` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE consultationRecord 
MODIFY appointmentId INT NULL;

ALTER TABLE appointments 
	MODIFY COLUMN id INT NOT NULL AUTO_INCREMENT;

ALTER TABLE appointments MODIFY COLUMN user_id VARCHAR(50);

ALTER TABLE appointments
  ADD CONSTRAINT fk_appointments_user
  FOREIGN KEY (user_id) REFERENCES users(id)
  ON DELETE CASCADE;
--
-- Dumping data for table `appointments`
--
SELECT * FROM `appointments`;
-- DELETE FROM `appointments` WHERE `id` > 1;


INSERT INTO `appointments` 
(`id`, `user_id`, `date`, `time`, `purpose`, `campus`, `type`, `doctor`, `status`, 
 `doctor_note`, `medication`, `cancellation_note`, `created_at`, `updated_at`) 
VALUES
-- Jake Rico (User ID 1)
(1, 1, '2025-12-15', '09:00:00', 'Routine dental cleaning', 'Main', 'Dental', 'Dr. Santos', 'Confirmed', 'Teeth cleaning scheduled', NULL, NULL, NOW(), NOW()),
(2, 1, '2025-12-20', '14:30:00', 'Annual health check-up', 'Basak', 'Check-up', 'Dr. Reyes', 'Pending', NULL, NULL, NULL, NOW(), NOW()),

-- Carlos Mendoza (User ID 7)
(3, 7, '2025-12-16', '10:00:00', 'Cavity filling', 'Main', 'Dental', 'Dr. Cruz', 'Completed', 'Procedure successful', 'Ibuprofen 200mg', NULL, NOW(), NOW()),

-- Sofia Ramos (User ID 8)
(4, 8, '2025-12-17', '11:00:00', 'Blood pressure monitoring', 'Basak', 'Check-up', 'Dr. Lopez', 'Confirmed', 'Patient stable', NULL, NULL, NOW(), NOW()),

-- Daniel Fernandez (User ID 9)
(5, 9, '2025-12-18', '13:00:00', 'Wisdom tooth consultation', 'Main', 'Dental', 'Dr. Santos', 'Pending', NULL, NULL, NULL, NOW(), NOW()),

-- Clarisse Tan (User ID 10)
(6, 10, '2025-12-19', '15:00:00', 'Follow-up check-up', 'Basak', 'Check-up', 'Dr. Reyes', 'Cancelled', NULL, NULL, 'Patient unavailable', NOW(), NOW()),

-- Patrick Lim (User ID 11)
(7, 11, '2025-12-21', '09:30:00', 'Dental braces adjustment', 'Main', 'Dental', 'Dr. Cruz', 'Confirmed', 'Adjustment needed', NULL, NULL, NOW(), NOW()),

-- Katrina Lopez (User ID 12)
(8, 12, '2025-12-22', '10:30:00', 'General wellness exam', 'Basak', 'Check-up', 'Dr. Lopez', 'Completed', 'All vitals normal', NULL, NULL, NOW(), NOW()),

-- Miguel Torres (User ID 13)
(9, 13, '2025-12-23', '11:15:00', 'Tooth extraction', 'Main', 'Dental', 'Dr. Santos', 'Confirmed', 'Extraction scheduled', 'Amoxicillin 500mg', NULL, NOW(), NOW()),

-- Jasmine Villanueva (User ID 14)
(10, 14, '2025-12-24', '14:00:00', 'Routine check-up', 'Basak', 'Check-up', 'Dr. Reyes', 'Pending', NULL, NULL, NULL, NOW(), NOW()),

-- Rafael Gonzales (User ID 15)
(11, 15, '2025-12-25', '09:45:00', 'Dental cleaning', 'Main', 'Dental', 'Dr. Cruz', 'Completed', 'Cleaning successful', NULL, NULL, NOW(), NOW()),

-- Andrea Santos (User ID 16)
(12, 16, '2025-12-26', '10:15:00', 'Blood sugar test', 'Basak', 'Check-up', 'Dr. Lopez', 'Confirmed', 'Patient advised diet control', NULL, NULL, NOW(), NOW()),

-- Christian Mendoza (User ID 17)
(13, 17, '2025-12-27', '13:30:00', 'Dental x-ray', 'Main', 'Dental', 'Dr. Santos', 'Pending', NULL, NULL, NULL, NOW(), NOW()),

-- Sophia Garcia (User ID 18)
(14, 18, '2025-12-28', '15:30:00', 'Annual physical exam', 'Basak', 'Check-up', 'Dr. Reyes', 'Confirmed', 'Patient cleared for sports', NULL, NULL, NOW(), NOW()),

-- Miguel Fernandez (User ID 19)
(15, 19, '2025-12-29', '09:00:00', 'Root canal consultation', 'Main', 'Dental', 'Dr. Cruz', 'Cancelled', NULL, NULL, 'Doctor unavailable', NOW(), NOW()),

-- Isabella Reyes (User ID 20)
(16, 20, '2025-12-30', '10:45:00', 'Routine check-up', 'Basak', 'Check-up', 'Dr. Lopez', 'Completed', 'Patient healthy', NULL, NULL, NOW(), NOW()),

-- Alex Morales (User ID 21)
(17, 21, '2025-12-31', '11:30:00', 'Dental whitening', 'Main', 'Dental', 'Dr. Santos', 'Confirmed', 'Whitening scheduled', NULL, NULL, NOW(), NOW());
-- --------------------------------------------------------

--
-- Table structure for table `remember_tokens`
--

CREATE TABLE `remember_tokens` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `remember_tokens`
--


INSERT INTO `remember_tokens` (`id`, `user_id`, `token`, `expires_at`, `created_at`) VALUES
(10, 4, 'c1ab3a63df7aa16edbaa4a881d9bfd4b5d23c19a1d0fc3f483788280f55429e0', '2025-12-21 13:08:29', '2025-11-21 05:08:29'),
(39, 1, 'cd68b62374b4750529a5c5d716f77adf53f5380d619b35edaae83f9009f1a466', '2026-01-06 11:38:04', '2025-12-07 11:38:04');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` int NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `idle_time` int NOT NULL DEFAULT '15' COMMENT 'Idle time in minutes before auto-lock',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `name`, `description`, `idle_time`, `created_at`, `updated_at`) VALUES
(1, 'admin', 'Administrator with full system access', 30, '2025-11-20 15:03:13', '2025-12-07 06:49:37'),
(2, 'doctor', 'Medical doctor with patient management access', 20, '2025-11-20 15:03:13', '2025-11-20 15:29:26'),
(3, 'ssd', 'security', 15, '2025-11-20 15:03:13', '2025-11-28 07:49:08'),
(4, 'clinic-staff', 'General clinic staff and reads member', 15, '2025-11-20 15:03:13', '2025-11-28 07:49:22'),
(5, 'student', 'Patient with limited access', 10, '2025-11-20 15:03:13', '2025-11-28 07:48:13');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `firstname` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lastname` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gender` enum('m','f') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_id` int NOT NULL DEFAULT '5',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `student_id` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `department` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `program_year` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `users`
  CHANGE COLUMN `program_year` `year_level` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  ADD COLUMN `program` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `department`;
  
SELECT * FROM users WHERE allergyId > 5;
SELECT * FROM allergyInfo;
ALTER TABLE `users`
	ADD UNIQUE INDEX idx_users_student_id (student_id);

CREATE TABLE if NOT EXISTS patientRecord (
	recordId INT AUTO_INCREMENT PRIMARY KEY,
    studentId VARCHAR(50) COLLATE utf8mb4_unicode_ci, 
		FOREIGN KEY(studentId) REFERENCES `users` (`student_id`)
        ON DELETE CASCADE,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
		ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE allergyInfo (
	allergyId INT AUTO_INCREMENT PRIMARY KEY,
	studentId VARCHAR(50) COLLATE utf8mb4_unicode_ci, 
		FOREIGN KEY(studentId) REFERENCES `users` (`student_id`)
        ON DELETE CASCADE,
	allergens TEXT,
	conditions TEXT,
	current_medications TEXT,
	emergency_contact_name VARCHAR(100),
	emergency_contact_number VARCHAR(20)
);

CREATE TABLE medicalCertificate (
	certId INT AUTO_INCREMENT PRIMARY KEY,
    recordId INT NOT NULL,
		FOREIGN KEY (recordId) REFERENCES patientRecord(recordId),
	dateIssued DATE NOT NULL,
    reason TEXT
);

CREATE TABLE dentalRecord (
	dentalId INT AUTO_INCREMENT PRIMARY KEY,
    recordId INT NOT NULL,
		FOREIGN KEY (recordId) REFERENCES patientRecord(recordId),
    date DATE NOT NULL,
    service VARCHAR(255),
    notes TEXT
);

CREATE TABLE consultationRecord (
	consultationId INT AUTO_INCREMENT PRIMARY KEY,
    recordId INT NOT NULL,
		FOREIGN KEY (recordId) REFERENCES patientRecord(recordId),
	appointmentId INT NOT NULL,
		FOREIGN KEY (appointmentId) REFERENCES `appointments`(`id`)
        ON DELETE SET NULL,
    date DATE NOT NULL,
    doctorId VARCHAR (50)
);

CREATE TABLE assessment (
	assessmentId INT AUTO_INCREMENT PRIMARY KEY,
    consultationId INT NOT NULL,
		FOREIGN KEY (consultationId) REFERENCES consultationRecord(consultationId)
        ON DELETE CASCADE,
    reason_for_visit TEXT,
    temperature FLOAT,
    blood_pressure VARCHAR (20),
    pulse_rate INT,
    respiratory_rate INT,
    diagnosis TEXT,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE prescription (
	prescriptionId INT AUTO_INCREMENT PRIMARY KEY,
    consultationId INT NOT NULL,
		FOREIGN KEY (consultationId) REFERENCES consultationRecord (consultationId),
	medication_name VARCHAR(255),
    dosage VARCHAR(100),
    duration VARCHAR(100),
    indication TEXT,
    additional_notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

--
-- Dumping data for table `users`
--

-- USE josenicare_db;
-- SHOW TABLES;

CREATE TABLE department (
    departmentID INT AUTO_INCREMENT PRIMARY KEY,
    departmentShortName VARCHAR(50) NOT NULL,   
    departmentFullName VARCHAR(255) NOT NULL,   
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE program (
    programID INT AUTO_INCREMENT PRIMARY KEY,
    departmentID INT NOT NULL,
		FOREIGN KEY (departmentID) REFERENCES department(departmentID) ON DELETE CASCADE,
    programShortName VARCHAR(50) NOT NULL,
    programFullName VARCHAR(255) NOT NULL
);

INSERT INTO department (departmentShortName, departmentFullName) VALUES
('SBM', 'School of Business and Management'),
('SAS', 'School of Arts and Sciences'),
('SAMS', 'School of Allied Medical Sciences'),
('SOE', 'School of Education'),
('SOEng', 'School of Engineering'),
('SCS', 'School of Computer Studies');

INSERT INTO program (departmentID, programShortName, programFullName) VALUES
-- School of Business and Management (departmentID = 1)
(1, 'BSA', 'Bachelor of Science in Accountancy'),
(1, 'BSBA-FM', 'Bachelor of Science in Business Administration Major in Financial Management'),
(1, 'BSBA-HRM', 'Bachelor of Science in Business Administration Major in Human Resource Management'),
(1, 'BSBA-MM', 'Bachelor of Science in Business Administration Major in Marketing Management'),
(1, 'BSBA-OM', 'Bachelor of Science in Business Administration Major in Operations Management'),
(1, 'BSEntrep', 'Bachelor of Science in Entrepreneurship'),
(1, 'BSHM', 'Bachelor of Science in Hospitality Management'),
(1, 'BSTourism', 'Bachelor of Science in Tourism Management'),

-- School of Arts and Sciences (departmentID = 2)
(2, 'BAComm', 'Bachelor of Arts in Communication'),
(2, 'BAELS', 'Bachelor of Arts in English Language Studies'),
(2, 'BAIS', 'Bachelor of Arts in International Studies'),
(2, 'BAJournalism', 'Bachelor of Arts in Journalism'),
(2, 'BSPsych', 'Bachelor of Science in Psychology'),
(2, 'BSBio', 'Bachelor of Science in Biology'),

-- School of Allied Medical Sciences (departmentID = 3)
(3, 'BSN', 'Bachelor of Science in Nursing'),
(3, 'BSMedTech', 'Bachelor of Science in Medical Technology'),
(3, 'BSPharm', 'Bachelor of Science in Pharmacy'),

-- School of Education (departmentID = 4)
(4, 'BEEd', 'Bachelor of Elementary Education'),
(4, 'BSEd', 'Bachelor of Secondary Education'),

-- School of Engineering (departmentID = 5)
(5, 'BSCE', 'Bachelor of Science in Civil Engineering'),
(5, 'BSEE', 'Bachelor of Science in Electrical Engineering'),
(5, 'BSME', 'Bachelor of Science in Mechanical Engineering'),
(5, 'BSArch', 'Bachelor of Science in Architecture'),

-- School of Computer Studies (departmentID = 6)
(6, 'BSCS', 'Bachelor of Science in Computer Science'),
(6, 'BSIT', 'Bachelor of Science in Information Technology'),
(6, 'BSIS', 'Bachelor of Science in Information Systems'),
(6, 'BSEMC', 'Bachelor of Science in Entertainment and Multimedia Computing'),
(6, 'BSGD', 'Bachelor of Science in Game Development');

--
-- Indexes for table `appointments`
--
ALTER TABLE `appointments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_appointments_date` (`date`),
  ADD KEY `idx_appointments_status` (`status`),
  ADD KEY `idx_appointments_user_id` (`user_id`);

--
-- Indexes for table `remember_tokens`
--
ALTER TABLE `remember_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `expires_at` (`expires_at`),
  ADD KEY `idx_token_expires` (`token`,`expires_at`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `fk_role_id` (`role_id`),
  ADD KEY `idx_firstname` (`firstname`),
  ADD KEY `idx_lastname` (`lastname`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `appointments`
--
ALTER TABLE `appointments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `remember_tokens`
--
ALTER TABLE `remember_tokens`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `appointments`
--
ALTER TABLE `appointments`
  ADD CONSTRAINT `appointments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `remember_tokens`
--
ALTER TABLE `remember_tokens`
  ADD CONSTRAINT `remember_tokens_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_role_id` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;
COMMIT;

CREATE TABLE if NOT EXISTS items (
	itemId INT PRIMARY KEY AUTO_INCREMENT,
    itemName VARCHAR (100) NOT NULL,
    category VARCHAR (100) NOT NULL,
    quantity INT NOT NULL,
    unit VARCHAR (15) NOT NULL,
    description VARCHAR (100),
    status VARCHAR (15),
	expirationDate DateTime NOT NULL
);
ALTER TABLE items MODIFY itemId INT NOT NULL AUTO_INCREMENT;

CREATE TABLE if NOT EXISTS itemAlert (
    alertId INT AUTO_INCREMENT PRIMARY KEY,
    itemId INT,
    FOREIGN KEY (itemId)
        REFERENCES items (itemId)
        ON DELETE CASCADE,
    type VARCHAR(100),
    generatedAt DATETIME
);

INSERT  INTO items (itemName, category, quantity, unit, description, status, expirationDate) VALUES
('Paracetamol', 'Medicine', 18, 'Tablets', 'Used for fever and headache', 'Low Stock', '2025-03-14 00:00:00'),
('Gauze Pads', 'First Aid', 0, 'Pack', '', 'Out of Stock', '2027-01-01 00:00:00'),
('Surgical Gloves', 'PPE', 4, 'Box', '', 'Low Stock', '2026-06-01 00:00:00'),
('Fluoride Gel', 'Dental', 2, 'Tube', '', 'Low Stock', '2025-02-01 00:00:00'),
('Nebulizer Set', 'Emergency', 3, 'Piece', '', 'In Stock', '9999-12-31 00:00:00'),
('Digital Thermometer', 'Equipment', 7, 'Piece', '', 'In Stock', '9999-12-31 00:00:00'),
('Alcohol 70% Solution', 'Operations', 0, 'Bottle', '', 'Out of Stock', '2025-05-01 00:00:00'),
('Cetirizine', 'Medicine', 42, 'Box', '', 'In Stock', '2026-10-20 00:00:00'),
('Oral Rehydration Salt', 'Medicine', 95, 'Sachet', '', 'In Stock', '2025-11-05 00:00:00'),
('Betadine Solution', 'First Aid', 6, 'Bottle', '', 'In Stock', '2026-04-10 00:00:00'),
('Hydrogen Peroxide', 'First Aid', 12, 'Bottle', '', 'In Stock', '2025-08-13 00:00:00'),
('Disposable Face Masks', 'PPE', 27, 'Box', '', 'In Stock', '2026-12-01 00:00:00');

INSERT  INTO items (itemName, category, quantity, unit, description, status, expirationDate) VALUES
('Alaxan', 'Medicine', 5, 'Tablets', 'Used for fever and headache', 'Low Stock', '2026-12-14 00:00:00');

INSERT INTO `users` (`id`, `email`, `firstname`, `lastname`, `gender`, `password`, `role_id`, `created_at`, `updated_at`, `student_id`, `department`, `program`, `year_level`) VALUES
(1, 'janlurence.espinosa.23@usjr.edu.ph', 'Jake', 'Rico', 'm', '$2y$12$OOLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 1, '2025-11-09 16:24:20', '2025-11-28 08:27:32', '2025001234', 'School of Computer Studies', 'Information Technology', '3'),
(2, 'maria.santos.23@usjr.edu.ph', 'Maria', 'Santos', 'f', '$2y$12$XkLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-10 09:15:00', '2025-11-28 08:27:32', '2025005678', 'School of Business and Management', 'Business Administration', '2'),
(3, 'juan.delacruz.23@usjr.edu.ph', 'Juan', 'Dela Cruz', 'm', '$2y$12$YOLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-11 14:30:00', '2025-11-28 08:27:32', '2025012345', 'School of Computer Studies', 'Computer Science', '1'),
(4, 'angelica.reyes.23@usjr.edu.ph', 'Angelica', 'Reyes', 'f', '$2y$12$ZOLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-12 10:45:00', '2025-11-28 08:27:32', '2025016789', 'School of Business and Management', 'Accountancy', '4'),
(5, 'mark.cruz.23@usjr.edu.ph', 'Mark', 'Cruz', 'm', '$2y$12$AOLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-13 08:20:00', '2025-11-28 08:27:32', '2025023456', 'School of Computer Studies', 'Information Systems', '2'),
(6, 'bea.garcia.23@usjr.edu.ph', 'Bea', 'Garcia', 'f', '$2y$12$BOLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-14 11:00:00', '2025-11-28 08:27:32', '2025027890', 'School of Business and Management', 'Marketing Management', '3'),
(7, 'carlos.mendoza.23@usjr.edu.ph', 'Carlos', 'Mendoza', 'm', '$2y$12$COLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-15 13:40:00', '2025-11-28 08:27:32', '2025034567', 'School of Computer Studies', 'Software Engineering', '4'),
(8, 'sofia.ramos.23@usjr.edu.ph', 'Sofia', 'Ramos', 'f', '$2y$12$DOLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-16 15:25:00', '2025-11-28 08:27:32', '2025038901',  'School of Business and Management', 'Financial Management', '1'),
(9, 'daniel.fernandez.23@usjr.edu.ph', 'Daniel', 'Fernandez', 'm', '$2y$12$EOLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-17 09:50:00', '2025-11-28 08:27:32', '2025045678',  'School of Computer Studies', 'Data Science', '3'), 
(10, 'clarisse.tan.23@usjr.edu.ph', 'Clarisse', 'Tan', 'f', '$2y$12$FOLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-18 12:10:00', '2025-11-28 08:27:32', '2025049012', 'School of Business and Management', 'Human Resource Management', '2'),
(11, 'patrick.lim.23@usjr.edu.ph', 'Patrick', 'Lim', 'm', '$2y$12$GOLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-19 14:55:00', '2025-11-28 08:27:32', '2025056789', 'School of Computer Studies', 'Cybersecurity', '4'),
(12, 'katrina.lopez.23@usjr.edu.ph', 'Katrina', 'Lopez', 'f', '$2y$12$HOLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-20 16:35:00', '2025-11-28 08:27:32', '2025050123', 'School of Business and Management', 'Economics', '1'),
(13, 'miguel.torres.23@usjr.edu.ph', 'Miguel', 'Torres', 'm', '$2y$12$IOLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-21 10:05:00', '2025-11-28 08:27:32', '2025063456', 'School of Computer Studies', 'Artificial Intelligence', '2'),
(14, 'jasmine.villanueva.23@usjr.edu.ph', 'Jasmine', 'Villanueva', 'f', '$2y$12$JOLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-22 11:45:00', '2025-11-28 08:27:32', '2025067890', 'School of Business and Management', 'Tourism Management', '3'),
(15, 'rafael.gonzales.23@usjr.edu.ph', 'Rafael', 'Gonzales', 'm', '$2y$12$KOLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-23 13:20:00', '2025-11-28 08:27:32', '2025071234', 'School of Computer Studies', 'Game Development', '1');

-- Patient records
INSERT INTO patientRecord (studentId, created_at, updated_at) VALUES
('2025001234', NOW(), NOW()),
('2025005678', NOW(), NOW()),
('2025012345', NOW(), NOW()),
('2025016789', NOW(), NOW()),
('2025023456', NOW(), NOW()),
('2025027890', NOW(), NOW()),
('2025034567', NOW(), NOW()),
('2025038901', NOW(), NOW()),
('2025045678', NOW(), NOW()),
('2025049012', NOW(), NOW()),
('2025056789', NOW(), NOW()),
('2025050123', NOW(), NOW()),
('2025063456', NOW(), NOW()),
('2025067890', NOW(), NOW()),
('2025071234', NOW(), NOW());

-- Allergy info tied directly to studentId
INSERT INTO allergyInfo (studentId, allergens, conditions, current_medications, emergency_contact_name, emergency_contact_number) VALUES
('2025005678', 'Peanuts', 'Asthma', 'Salbutamol inhaler', 'Jose Santos', '09171234567'),
('2025016789', 'Seafood', 'Eczema', 'Cetirizine', 'Ana Reyes', '09281234567'),
('2025034567', 'Dust mites', 'Allergic rhinitis', 'Loratadine', 'Carlos Mendoza Sr.', '09391234567'),
('2025049012', 'Penicillin', 'None', 'None', 'Clarisse Tan', '09451234567'),
('2025063456', 'Shellfish', 'Mild asthma', 'Ventolin', 'Miguel Torres Sr.', '09561234567');

-- More users
INSERT INTO `users` (`id`, `email`, `firstname`, `lastname`, `gender`, `password`, `role_id`, `created_at`, `updated_at`, `student_id`, `department`, `program`, `year_level`) VALUES
(16, 'andrea.santos.23@usjr.edu.ph', 'Andrea', 'Santos', 'f', '$2y$12$LOLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-24 09:10:00', '2025-11-28 08:27:32', '2025075678', 'School of Business and Management', 'Marketing Management', '2'),
(17, 'christian.mendoza.23@usjr.edu.ph', 'Christian', 'Mendoza', 'm', '$2y$12$MOLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-25 11:20:00', '2025-11-28 08:27:32', '2025079012', 'School of Computer Studies', 'Software Engineering', '3'),
(18, 'sophia.garcia.23@usjr.edu.ph', 'Sophia', 'Garcia', 'f', '$2y$12$NOLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-26 14:05:00', '2025-11-28 08:27:32', '2025082345', 'School of Business and Management', 'Financial Management', '1'),
(19, 'miguel.fernandez.23@usjr.edu.ph', 'Miguel', 'Fernandez', 'm', '$2y$12$OOLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-27 08:45:00', '2025-11-28 08:27:32', '2025086789', 'School of Computer Studies', 'Information Technology', '4'),
(20, 'isabella.reyes.23@usjr.edu.ph', 'Isabella', 'Reyes', 'f', '$2y$12$POLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-28 10:30:00', '2025-11-28 08:27:32', '2025090123', 'School of Business and Management', 'Economics', '2');

-- Patient records for those users
INSERT INTO patientRecord (studentId, created_at, updated_at) VALUES
('2025075678', NOW(), NOW()),
('2025079012', NOW(), NOW()),
('2025082345', NOW(), NOW()),
('2025086789', NOW(), NOW()),
('2025090123', NOW(), NOW());

-- Allergy info tied directly to studentId
INSERT INTO allergyInfo (studentId, allergens, conditions, current_medications, emergency_contact_name, emergency_contact_number) VALUES
('2025075678', 'Eggs', 'Mild asthma', 'Ventolin inhaler', 'Rosa Santos', '09671234567'),
('2025079012', 'Latex', 'Skin sensitivity', 'Hydrocortisone cream', 'Luis Mendoza', '09781234567'),
('2025082345', 'Milk', 'Lactose intolerance', 'None', 'Elena Garcia', '09891234567'),
('2025086789', 'Soy', 'None', 'None', 'Carlos Fernandez', '09901234567'),
('2025090123', 'Bee stings', 'Anaphylaxis risk', 'EpiPen', 'Miguel Reyes', '09101234567');

-- Users from other departments
INSERT INTO `users` 
(`id`, `email`, `firstname`, `lastname`, `gender`, `password`, `role_id`, `created_at`, `updated_at`, `student_id`, `department`, `program`, `year_level`) VALUES
(21, 'alex.morales.23@usjr.edu.ph', 'Alex', 'Morales', 'm', '$2y$12$L1OLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-29 09:00:00', '2025-12-11 19:04:00', '2025094567', 'School of Nursing', 'BS Nursing', '2'),
(22, 'julia.estrada.23@usjr.edu.ph', 'Julia', 'Estrada', 'f', '$2y$12$M1OLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-29 10:15:00', '2025-12-11 19:04:00', '2025098901', 'School of Education', 'Secondary Education', '3'),
(23, 'ryan.delosreyes.23@usjr.edu.ph', 'Ryan', 'Delos Reyes', 'm', '$2y$12$N1OLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-30 08:45:00', '2025-12-11 19:04:00', '2025102345', 'School of Engineering', 'Civil Engineering', '4'),
(24, 'hannah.gutierrez.23@usjr.edu.ph', 'Hannah', 'Gutierrez', 'f', '$2y$12$O1OLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-11-30 13:20:00', '2025-12-11 19:04:00', '2025106789', 'School of Law', 'Bachelor of Laws', '1'),
(25, 'marco.rivera.23@usjr.edu.ph', 'Marco', 'Rivera', 'm', '$2y$12$P1OLvtVEmhfqMVFTE6Q9ZqekGIErT9Vr2tlPL.wiyKo7udQSskZ5W6', 5, '2025-12-01 09:50:00', '2025-12-11 19:04:00', '2025110123', 'School of Medicine', 'Doctor of Medicine', '2');

-- Patient records for those users
INSERT INTO patientRecord (studentId, created_at, updated_at) VALUES
('2025094567', NOW(), NOW()),  -- Alex Morales, Nursing
('2025098901', NOW(), NOW()),  -- Julia Estrada, Education
('2025102345', NOW(), NOW()),  -- Ryan Delos Reyes, Engineering
('2025106789', NOW(), NOW()),  -- Hannah Gutierrez, Law
('2025110123', NOW(), NOW());  -- Marco Rivera, Medicine


SELECT recordId FROM patientRecord;
-- Dental records tied to patientRecord.recordId
INSERT INTO dentalRecord (recordId, date, service, notes) VALUES
(68, '2025-11-21', 'Tooth extraction', 'Wisdom tooth removed successfully'),   -- studentId 2025005678
(69, '2025-11-23', 'Dental cleaning', 'Routine prophylaxis'),                  -- studentId 2025012345
(70, '2025-11-24', 'Filling', 'Cavity filled on molar'),                       -- studentId 2025034567
(71, '2025-11-25', 'Orthodontic check-up', 'Braces adjustment'),               -- studentId 2025045678
(72, '2025-11-27', 'Dental cleaning', 'Recommended flossing daily');          -- studentId 2025067890

-- Medical certificates tied to patientRecord.recordId
INSERT INTO medicalCertificate (recordId, dateIssued, reason) VALUES
(68, '2025-11-20', 'Fever and flu, excused from classes'),                     -- studentId 2025001234
(69, '2025-11-22', 'Fitness certificate for varsity tryouts'),                 -- studentId 2025012345
(70, '2025-11-25', 'Stomach pain, excused for 2 days'),                        -- studentId 2025023456
(71, '2025-11-26', 'Medical clearance for internship'),                        -- studentId 2025038901
(72, '2025-11-28', 'Recovered from dengue fever, fit to return');             -- studentId 2025050123

-- Consultation records tied to patientRecord.recordId
INSERT INTO consultationRecord (consultationId, recordId, appointmentId, date, doctorId)
VALUES
  (1001, 68, 1, '2025-12-15 09:00:00', 301), -- Jake Rico, dental cleaning
  (1002, 69, 3, '2025-12-16 10:00:00', 302), -- Carlos Mendoza, cavity filling
  (1003, 70, 4, '2025-12-17 11:00:00', 303), -- Sofia Ramos, BP monitoring
  (1004, 71, 5, '2025-12-18 13:00:00', 301), -- Daniel Fernandez, wisdom tooth consult
  (1005, 72, 6, '2025-12-19 15:00:00', 302); -- Clarisse Tan, follow-up check-up
-- Assessments tied to consultationRecord.consultationId (1..5 auto-generated)

-- Assessments tied to consultationRecord.consultationId (1001–1005)
INSERT INTO assessment (consultationId, reason_for_visit, temperature, blood_pressure, pulse_rate, respiratory_rate, diagnosis, notes) VALUES
(1001, 'Routine dental cleaning', 36.6, '118/76', 78, 16, 'Healthy dentition', 'Scheduled cleaning, no issues found'),
(1002, 'Cavity filling', 37.2, '120/80', 82, 18, 'Dental caries', 'Procedure successful, patient advised oral hygiene'),
(1003, 'Blood pressure monitoring', 36.8, '125/85', 76, 17, 'Hypertension (controlled)', 'Patient stable, continue monitoring'),
(1004, 'Wisdom tooth consultation', 37.0, '119/78', 80, 18, 'Impacted wisdom tooth', 'Referred for extraction'),
(1005, 'Follow-up check-up', 36.9, '117/75', 74, 16, 'General wellness', 'Patient recovering well, no new concerns');

-- Prescriptions tied to consultationRecord.consultationId (1001–1005)
INSERT INTO prescription (consultationId, medication_name, dosage, duration, indication, additional_notes) VALUES
(1001, 'Fluoride rinse', 'Use once daily', '14 days', 'Dental hygiene', 'Avoid eating immediately after use'),
(1002, 'Ibuprofen', '400mg every 8 hours', '5 days', 'Post-procedure pain', 'Take with food'),
(1003, 'Amlodipine', '5mg once daily', '30 days', 'Blood pressure control', 'Continue regular monitoring'),
(1004, 'Amoxicillin', '500mg every 8 hours', '7 days', 'Dental infection prophylaxis', 'Complete full course'),
(1005, 'Multivitamins', '1 tablet daily', '30 days', 'General recovery support', 'Maintain balanced diet');

CREATE TABLE healthSurvey (
    surveyId INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    healthRating INT NOT NULL,
    areaAffected VARCHAR(255) NOT NULL,
    symptoms VARCHAR(500) CHARACTER SET utf8mb4 NOT NULL,
    symptom_start_date DATE,
    painScale INT,
    pain_location VARCHAR(255),
    medication_taken BOOLEAN,
    CONSTRAINT fk_healthSurvey_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

INSERT INTO healthSurvey (user_id, healthRating, areaAffected, symptoms, symptom_start_date, painScale, pain_location, medication_taken) VALUES
(1, 6, 'Head', 'Persistent headache, mild dizziness', '2025-12-01', 5, 'Forehead', TRUE),
(2, 8, 'Chest', 'Cough, mild shortness of breath', '2025-12-03', 4, 'Upper chest', FALSE),
(3, 5, 'Stomach', 'Abdominal pain, nausea, bloating', '2025-12-05', 6, 'Lower abdomen', TRUE),
(4, 7, 'Head', 'Occasional migraine, sensitivity to light', '2025-12-07', 7, 'Temple area', TRUE),
(5, 9, 'Chest', 'Mild chest tightness after exercise', '2025-12-09', 3, 'Center chest', FALSE),
(6, 4, 'Stomach', 'Sharp stomach cramps, diarrhea', '2025-12-10', 8, 'Upper stomach', TRUE);

INSERT INTO healthSurvey (user_id, healthRating, areaAffected, symptoms, symptom_start_date, painScale, pain_location, medication_taken) VALUES
(7, 5, 'Head', 'Frequent tension headaches, mild eye strain', '2025-12-11', 6, 'Back of head', TRUE),
(8, 7, 'Chest', 'Occasional chest discomfort when climbing stairs', '2025-12-11', 4, 'Left chest', FALSE),
(9, 4, 'Stomach', 'Severe stomach cramps, vomiting', '2025-12-12', 8, 'Lower stomach', TRUE),
(10, 8, 'Head', 'Mild migraine triggered by stress', '2025-12-12', 5, 'Right temple', TRUE),
(11, 6, 'Chest', 'Persistent cough, mild wheezing', '2025-12-13', 6, 'Center chest', TRUE),
(12, 9, 'Stomach', 'Indigestion after heavy meals', '2025-12-13', 3, 'Upper abdomen', FALSE),
(13, 7, 'Head', 'Occasional dizziness, light headache', '2025-12-14', 4, 'Top of head', FALSE),
(14, 5, 'Chest', 'Sharp pain during deep breaths', '2025-12-14', 7, 'Right chest', TRUE),
(15, 8, 'Stomach', 'Mild bloating, stomach discomfort', '2025-12-15', 4, 'Mid stomach', FALSE),
(16, 6, 'Head', 'Recurring migraine with nausea', '2025-12-15', 7, 'Left temple', TRUE);
SELECT * FROM users;
SELECT * FROM patientRecord;
SELECT * FROM consultationRecord;
SELECT * FROM appointments;
SELECT * FROM assessment;
-- DELETE FROM assessment WHERE assessmentId = 16;
SELECT * FROM prescription;
SELECT * FROM allergyInfo;
SELECT * FROM dentalRecord;
SELECT * FROM medicalCertificate;
USE josenicare_db;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
