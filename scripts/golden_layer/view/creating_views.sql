--================================================================================================================
-- SCHEMA CREATION: GOLD LAYER
-- This schema is designed for aggregated and structured data views, providing high-level insights for the hospital system.
-- WARNING: Ensure that the dependent schemas (silver, bronze) and their respective tables exist before executing this script.
--================================================================================================================
CREATE SCHEMA IF NOT EXISTS gold;

--================================================================================================================
-- VIEW: Patient Summary
-- DESCRIPTION: Aggregates essential patient information for quick access by healthcare providers.
-- WARNING: Ensure that sensitive patient data is handled securely and follows compliance regulations (e.g., HIPAA, GDPR).
--================================================================================================================
CREATE OR ALTER VIEW gold.patient_info AS
SELECT 
    patient_id,
    first_name,
    last_name,
    dob,
    gender,
    address,
    city,
    state,
    postal_code,
    phone_number,
    email,
    insurance_provider,
    insurance_policy_number,
    blood_type,
    allergies,
    medications,
    diagnosis,
    admission_date,
    discharge_date,
    emergency_contact_name,
    emergency_contact_phone,
    emergency_contact_relationship,
    insurance_expiration_date,
    blood_pressure,
    heart_rate,
    weight, 
    height,
    temperature
FROM silver.patient_info;

--================================================================================================================
-- VIEW: Doctor Assignments
-- DESCRIPTION: Displays the number of patients assigned to each doctor to help balance workload distribution.
-- WARNING: This view only provides a count. For detailed assignments, use the Patient_Doctor view.
--================================================================================================================
CREATE OR ALTER VIEW gold.number_of_doctors AS
SELECT 
    doctor_id,
    COUNT(patient_id) AS numb_patients
FROM silver.patient_info
GROUP BY doctor_id;

--================================================================================================================
-- VIEW: Billing Summary
-- DESCRIPTION: Provides a comprehensive overview of outstanding payments and billing history per patient.
-- WARNING: Ensure financial records are kept confidential and follow compliance regulations.
--================================================================================================================
CREATE OR ALTER VIEW gold.billing_summary AS
SELECT
    p.patient_id,
    b.billing_id,
    b.billing_date,
    b.due_date,
    b.payment_status
FROM silver.billing_info AS b
JOIN silver.patient_info AS p
ON p.patient_id = b.patient_id;

--================================================================================================================
-- VIEW: Room Availability
-- DESCRIPTION: Displays room status and availability to assist staff in locating free rooms.
-- WARNING: Ensure real-time updates are reflected correctly to prevent overbooking.
--================================================================================================================
CREATE OR ALTER VIEW gold.room_availability AS 
SELECT 
    room_number,
    room_type,
    capacity,
    current_occupancy,
    is_available,
    dwh_create_date
FROM silver.rooms_info;

--================================================================================================================
-- VIEW: Patient Room Allocation
-- DESCRIPTION: Links patients with their assigned rooms, displaying occupancy and admission details.
-- WARNING: Ensures patients are assigned rooms based on availability and medical needs.
--================================================================================================================
CREATE OR ALTER VIEW gold.patient_room_allocation AS 
SELECT
    r.room_number,
    r.room_type,
    r.capacity,
    r.current_occupancy,
    r.is_available,
    p.admission_date,
    p.discharge_date
FROM bronze.rooms_info AS r
JOIN silver.patient_info AS p
ON p.room_number = r.room_number AND p.admission_date <= p.discharge_date;

--================================================================================================================
-- VIEW: Patient-Doctor Assignments
-- DESCRIPTION: Displays the relationship between patients and their assigned doctors, including specialties.
-- WARNING: This view does not contain patient medical records, only assignment details.
--================================================================================================================
CREATE OR ALTER VIEW gold.patient_doctor AS 
SELECT
    d.doctor_id,
    d.first_name,
    d.last_name,
    d.phone_number,
    d.email
FROM silver.doctor_info AS d
JOIN silver.patient_info AS p
ON p.doctor_id = d.doctor_id;
