/*
-- =============================================================
-- Healthcare Management System (HMS) - Bronze Layer (Raw Data Storage)
-- =============================================================
-- PURPOSE:
-- This script defines the BRONZE layer for the ETL process.
-- The Bronze layer is responsible for raw data extraction from the source.
-- Data will be stored as NVARCHAR to allow all types of values (valid or invalid).
-- Transformation, data cleaning, and type casting will occur in the Silver layer.
-- =============================================================
-- ⚠ WARNINGS:
-- - This is a TEST version; expect raw and uncleaned data.
-- - All date-related fields are stored as NVARCHAR (to prevent BULK INSERT failures).
-- - This script DROPS existing tables before creating them (data loss risk).
-- - Designed for DEVELOPMENT and TESTING purposes only.
-- =============================================================
*/

-- Create Schema for Bronze Layer
CREATE SCHEMA bronze;
GO

-- =============================================================
-- Patient Information Table (Raw Data)
-- =============================================================
-- Stores raw patient data extracted from the source.
-- All values are stored as NVARCHAR for flexible ingestion.
-- This will be cleaned and transformed in the Silver layer.
-- =============================================================
IF OBJECT_ID ('bronze.patient_info', 'U') IS NOT NULL
    DROP TABLE bronze.patient_info;
CREATE TABLE bronze.patient_info (
    patient_id NVARCHAR(50),  -- Stored as NVARCHAR to allow all inputs
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    dob NVARCHAR(50),  -- Will be converted to DATE in Silver layer
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
    admission_date NVARCHAR(50),  -- Will be converted to DATE later
    discharge_date NVARCHAR(50),  -- Will be converted to DATE later
    emergency_contact_name NVARCHAR(50),
    emergency_contact_phone NVARCHAR(50),
    emergency_contact_relationship NVARCHAR(50),
    insurance_expiration_date NVARCHAR(50),  -- To be cleaned in Silver layer
    blood_pressure NVARCHAR(50),  -- To be converted to DECIMAL later
    heart_rate NVARCHAR(50),  -- To be converted to INT later
    weight NVARCHAR(50),  -- To be converted to INT later
    height NVARCHAR(50),
    temperature NVARCHAR(50)  -- To be converted to DECIMAL later
);
GO

-- =============================================================
-- Doctor Information Table
-- =============================================================
-- Stores raw doctor data. Primary key will be auto-generated.
-- =============================================================
IF OBJECT_ID ('bronze.doctor_info', 'U') IS NOT NULL
    DROP TABLE bronze.doctor_info;
CREATE TABLE bronze.doctor_info (
    doctor_id INT IDENTITY(1,1),  -- Auto-incremented ID
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    phone_number NVARCHAR(50),
    email NVARCHAR(50)
);
GO

-- =============================================================
-- Nurse Information Table
-- =============================================================
-- Stores raw nurse data.
-- =============================================================
IF OBJECT_ID ('bronze.nurses_info', 'U') IS NOT NULL
    DROP TABLE bronze.nurses_info;
CREATE TABLE bronze.nurses_info (
    nurse_id INT IDENTITY(1,1),
    first_name NVARCHAR(50),  -- Fixed typo (fist_name -> first_name)
    last_name NVARCHAR(50),
    phone_number NVARCHAR(50),
    email NVARCHAR(50)
);
GO

-- =============================================================
-- Billing Information Table
-- =============================================================
-- Stores raw patient billing data.
-- Financial fields are properly defined as DECIMAL.
-- =============================================================
IF OBJECT_ID ('bronze.billing_info', 'U') IS NOT NULL
    DROP TABLE bronze.billing_info;
CREATE TABLE bronze.billing_info (
    billing_id INT IDENTITY(1,1),
    patient_id NVARCHAR(50),  -- Foreign Key (to be implemented in Silver layer)
    total_amount DECIMAL(10,2),  -- Stores total billing amount
    amount_paid DECIMAL(10,2),
    billing_date NVARCHAR(50),  -- Stored as NVARCHAR; will be converted later
    due_date NVARCHAR(50),
    payment_status NVARCHAR(50),
    insurance_coverage NVARCHAR(50)
);
GO

-- =============================================================
-- Insurance Information Table
-- =============================================================
-- Stores raw insurance policy details.
-- =============================================================
IF OBJECT_ID ('bronze.insurance_info', 'U') IS NOT NULL
    DROP TABLE bronze.insurance_info;
CREATE TABLE bronze.insurance_info (
    insurance_id INT IDENTITY(1,1),
    patient_id NVARCHAR(50),  -- Foreign Key (to be implemented in Silver layer)
    insurance_provider NVARCHAR(50),
    policy_number NVARCHAR(50),
    coverage_start_date NVARCHAR(50),  -- Will be converted to DATE later
    coverage_end_date NVARCHAR(50)
);
GO

-- =============================================================
-- Room Information Table
-- =============================================================
-- Stores raw room allocation details.
-- =============================================================
IF OBJECT_ID ('bronze.rooms_info', 'U') IS NOT NULL
    DROP TABLE bronze.rooms_info;
CREATE TABLE bronze.rooms_info (
    room_number INT,  -- Unique room identifier
    room_type NVARCHAR(50),
    capacity INT,
    current_occupancy NVARCHAR(50),
    is_available NVARCHAR(50)  -- Will be converted to BIT (0/1) later
);
GO

-- =============================================================
-- 🔥 END OF SCRIPT 🔥
-- =============================================================
-- ✅ This script is part of the ETL pipeline.
-- ✅ It only extracts data from the source (no transformations).
-- ✅ The Silver layer will clean, format, and structure the data.
-- =============================================================
