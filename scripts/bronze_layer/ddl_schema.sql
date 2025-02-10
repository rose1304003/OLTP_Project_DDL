/*
-- =============================================================
-- Healthcare Management System (HMS) - SQL Database Schema  
-- =============================================================
-- PURPOSE:  
-- This script creates the database schema for a Healthcare Management System.  
-- It defines tables for patients, doctors, nurses, billing, insurance, and room allocations.  
-- The database ensures referential integrity and data consistency.  
-- =============================================================
-- ⚠ WARNINGS:  
-- - This script DROPS existing tables if they exist, leading to DATA LOSS.  
-- - Intended for TESTING and DEVELOPMENT environments only.  
-- - Requires Microsoft SQL Server. Ensure compatibility before execution.  
-- =============================================================
*/

-- Create Schema
CREATE SCHEMA bronze;
GO

-- =============================================================
-- Patient Information Table  
-- Stores detailed patient data, including personal info, medical history,  
-- emergency contacts, and vitals.  
-- =============================================================
IF OBJECT_ID ('bronze.patient_info', 'U') IS NOT NULL
    DROP TABLE bronze.patient_info;
CREATE TABLE bronze.patient_info (
    patient_id NVARCHAR(50) PRIMARY KEY,
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    dob DATE,
    gender NVARCHAR(50),
    address NVARCHAR(50),
    city NVARCHAR(50),
    state NVARCHAR(50),
    postal_code NVARCHAR(50),
    phone_number NVARCHAR(50),
    email NVARCHAR(50),
    insurance_provider NVARCHAR(50),
    insurance_policy_number NVARCHAR(50),
    blood_type NVARCHAR(50),
    allergies NVARCHAR(50),
    medications NVARCHAR(50),
    diagnosis NVARCHAR(50),
    admission_date DATE,
    discharge_date DATE,
    emergency_contact_name NVARCHAR(50),
    emergency_contact_phone NVARCHAR(50),
    emergency_contact_relationship NVARCHAR(50),
    insurance_expiration_date DATE,
    blood_pressure DECIMAL(5,2),
    heart_rate INT,
    weight INT, 
    height INT,
    temperature DECIMAL(4,2)
);
GO

-- =============================================================
-- Doctor Information Table  
-- Stores basic information about doctors.  
-- =============================================================
IF OBJECT_ID ('bronze.doctor_info', 'U') IS NOT NULL
    DROP TABLE bronze.doctor_info;
CREATE TABLE bronze.doctor_info (
    doctor_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    phone_number NVARCHAR(50),
    email NVARCHAR(50)
);
GO

-- =============================================================
-- Nurse Information Table  
-- Stores contact details of nurses.  
-- =============================================================
IF OBJECT_ID ('bronze.nurses_info', 'U') IS NOT NULL
    DROP TABLE bronze.nurses_info;
CREATE TABLE bronze.nurses_info (
    nurse_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(50),  -- Fixed typo (fist_name -> first_name)
    last_name NVARCHAR(50),
    phone_number NVARCHAR(50),
    email NVARCHAR(50)
);
GO

-- =============================================================
-- Billing Information Table  
-- Stores patient billing details, payments, and insurance coverage.  
-- =============================================================
IF OBJECT_ID ('bronze.billing_info', 'U') IS NOT NULL
    DROP TABLE bronze.billing_info;
CREATE TABLE bronze.billing_info (
    billing_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id NVARCHAR(50),  -- Added missing column
    total_amount DECIMAL(10,2),  -- Increased precision
    amount_paid DECIMAL(10,2),
    billing_date DATE,
    due_date DATE,
    payment_status NVARCHAR(50),
    insurance_coverage NVARCHAR(50),
    FOREIGN KEY (patient_id) REFERENCES bronze.patient_info(patient_id)
);
GO

-- =============================================================
-- Insurance Information Table  
-- Stores insurance details linked to patients.  
-- =============================================================
IF OBJECT_ID ('bronze.insurance_info', 'U') IS NOT NULL
    DROP TABLE bronze.insurance_info;
CREATE TABLE bronze.insurance_info (
    insurance_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id NVARCHAR(50),  -- Added missing column
    insurance_provider NVARCHAR(50),
    policy_number NVARCHAR(50),
    coverage_start_date DATE,  -- Fixed typo (covergae_start_date -> coverage_start_date)
    coverage_end_date DATE,
    FOREIGN KEY (patient_id) REFERENCES bronze.patient_info(patient_id)
);
GO

-- =============================================================
-- Rooms Information Table  
-- Tracks room availability and patient allocations.  
-- =============================================================
IF OBJECT_ID ('bronze.rooms_info', 'U') IS NOT NULL
    DROP TABLE bronze.rooms_info;
CREATE TABLE bronze.rooms_info (
    room_number INT PRIMARY KEY,  -- Added primary key
    room_type NVARCHAR(50),
    capacity INT,
    current_occupancy NVARCHAR(50),
    is_available NVARCHAR(50)  -- Fixed typo (is_availbale -> is_available)
);
GO
