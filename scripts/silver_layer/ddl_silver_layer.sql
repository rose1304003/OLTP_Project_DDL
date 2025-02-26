--- 🏥 SILVER LAYER DATABASE - PATIENT MANAGEMENT SYSTEM

-- 📋 Drop and Create Patient Info Table
IF OBJECT_ID ('silver.patient_info', 'U') IS NOT NULL
    DROP TABLE silver.patient_info;
CREATE TABLE silver.patient_info (
    patient_id NVARCHAR(50) PRIMARY KEY,  -- 🆔 Unique identifier for each patient
    first_name NVARCHAR(50),  -- 👤 First name
    last_name NVARCHAR(50),  -- 👤 Last name
    dob DATE,  -- 🎂 Date of Birth
    gender NVARCHAR(50),  -- ⚧ Gender (Male/Female/Other)
    address NVARCHAR(50),  -- 🏠 Address
    city NVARCHAR(50),
    state NVARCHAR(50),
    postal_code NVARCHAR(50),
    phone_number NVARCHAR(50),  -- 📞 Contact Number
    email NVARCHAR(50),  -- 📧 Email
    insurance_provider NVARCHAR(50),  -- 🏥 Insurance Provider
    insurance_policy_number NVARCHAR(50),  -- 📜 Policy Number
    blood_type NVARCHAR(50),  -- 🩸 Blood Type
    allergies NVARCHAR(255),  -- 🤧 Allergies
    medications NVARCHAR(255),  -- 💊 Medications
    diagnosis NVARCHAR(255),  -- 📄 Medical Diagnosis
    admission_date DATE,  -- 📅 Admission Date
    discharge_date DATE,  -- 📅 Discharge Date
    doctor_id INT,  -- 👨‍⚕️ Assigned Doctor
    nurse_id INT,  -- 👩‍⚕️ Assigned Nurse
    room_number INT,  -- 🛏 Room Assigned
    emergency_contact_name NVARCHAR(50),  -- 🚨 Emergency Contact Name
    emergency_contact_phone NVARCHAR(50),  -- 📞 Emergency Contact Number
    emergency_contact_relationship NVARCHAR(50),  -- 👨‍👩‍👧 Relationship
    insurance_expiration_date DATE,  -- 📆 Insurance Expiration Date
    blood_pressure DECIMAL(6,2),  -- 🩺 Blood Pressure
    heart_rate DECIMAL(6,2),  -- ❤️ Heart Rate
    weight DECIMAL(6,2),  -- ⚖️ Weight (kg)
    height DECIMAL(6,2),  -- 📏 Height (cm)
    temperature DECIMAL(6,2),  -- 🌡 Temperature (°C)
    dwh_create_date DATETIME2 DEFAULT GETDATE()  -- ⏳ Record Creation Timestamp
);
GO

-- 🩺 Drop and Create Doctor Info Table
IF OBJECT_ID ('silver.doctor_info', 'U') IS NOT NULL
    DROP TABLE silver.doctor_info;
CREATE TABLE silver.doctor_info (
    doctor_id INT PRIMARY KEY,  -- 🆔 Unique ID for Doctors
    first_name NVARCHAR(50),  -- 👨‍⚕️ First Name
    last_name NVARCHAR(50),  -- 👨‍⚕️ Last Name
    phone_number NVARCHAR(50),  -- 📞 Contact Number
    email NVARCHAR(50),  -- 📧 Email Address
    dwh_create_date DATETIME2 DEFAULT GETDATE()  -- ⏳ Record Creation Timestamp
);
GO

-- 👩‍⚕️ Drop and Create Nurses Info Table
IF OBJECT_ID ('silver.nurses_info', 'U') IS NOT NULL
    DROP TABLE silver.nurses_info;
CREATE TABLE silver.nurses_info (
    nurse_id INT PRIMARY KEY,  -- 🆔 Unique ID for Nurses
    first_name NVARCHAR(50),  -- 👩‍⚕️ First Name
    last_name NVARCHAR(50),  -- 👩‍⚕️ Last Name
    phone_number NVARCHAR(50),  -- 📞 Contact Number
    email NVARCHAR(50),  -- 📧 Email Address
    dwh_create_date DATETIME2 DEFAULT GETDATE()  -- ⏳ Record Creation Timestamp
);
GO

-- 💰 Drop and Create Billing Info Table
IF OBJECT_ID ('silver.billing_info', 'U') IS NOT NULL
    DROP TABLE silver.billing_info;
CREATE TABLE silver.billing_info (
    billing_id INT IDENTITY(1,1) PRIMARY KEY,  -- 🆔 Unique Billing ID
    patient_id NVARCHAR(50) REFERENCES silver.patient_info(patient_id),  -- 👤 Patient Reference
    total_amount DECIMAL(10,2),  -- 💲 Total Amount Billed
    amount_paid DECIMAL(10,2),  -- 💵 Amount Paid
    billing_date DATE,  -- 📅 Billing Date
    due_date DATE,  -- 📅 Payment Due Date
    payment_status NVARCHAR(50),  -- ✅ Payment Status (Paid/Pending)
    insurance_coverage NVARCHAR(50),  -- 🏥 Insurance Coverage Details
    dwh_create_date DATETIME2 DEFAULT GETDATE()  -- ⏳ Record Creation Timestamp
);
GO

-- 🏦 Drop and Create Insurance Info Table
IF OBJECT_ID ('silver.insurance_info', 'U') IS NOT NULL
    DROP TABLE silver.insurance_info;
CREATE TABLE silver.insurance_info (
    insurance_id INT IDENTITY(1,1) PRIMARY KEY,  -- 🆔 Unique Insurance ID
    patient_id NVARCHAR(50) REFERENCES silver.patient_info(patient_id),  -- 👤 Patient Reference
    insurance_provider NVARCHAR(50),  -- 🏥 Insurance Provider
    policy_number NVARCHAR(50),  -- 📜 Policy Number
    coverage_start_date DATE,  -- 📆 Coverage Start Date
    coverage_end_date DATE,  -- 📆 Coverage End Date
    dwh_create_date DATETIME2 DEFAULT GETDATE()  -- ⏳ Record Creation Timestamp
);
GO

-- 🚑 Drop and Create Rooms Info Table
IF OBJECT_ID ('silver.rooms_info', 'U') IS NOT NULL
    DROP TABLE silver.rooms_info;
CREATE TABLE silver.rooms_info (
    room_number INT PRIMARY KEY,  -- 🛏 Unique Room Number
    room_type NVARCHAR(50),  -- 🏠 Room Type (Private, Shared, ICU, etc.)
    capacity INT,  -- 👥 Maximum Capacity
    current_occupancy INT,  -- 🏥 Number of Patients Currently in Room
    is_available NVARCHAR(50),  -- ✅ Availability Status (Yes/No)
    dwh_create_date DATETIME2 DEFAULT GETDATE()  -- ⏳ Record Creation Timestamp
);
GO
