--============================================================
-- 🏥 PROCEDURE: Load Data into Silver Layer Tables
--============================================================

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '===================================';
        PRINT '🚀 Loading Silver Layer';
        PRINT '===================================';
        
        PRINT '-------------------------------------';
        PRINT '🗄 Loading CRM tables';
        PRINT '-------------------------------------';
        
        -- ✅ LOADING PATIENT INFORMATION INTO SILVER LAYER
        PRINT '>> Truncating Table: silver.patient_info';
        TRUNCATE TABLE silver.patient_info;
        PRINT '>> Inserting Data Into silver.patient_info';
        
        WITH RankedPatients AS (
            SELECT 
                patient_id,
                UPPER(LEFT(first_name, 1)) + LOWER(SUBSTRING(first_name, 2, LEN(first_name))) AS first_name,  
                UPPER(LEFT(last_name, 1)) + LOWER(SUBSTRING(last_name, 2, LEN(last_name))) AS last_name,  
                TRY_CONVERT(DATE, dob, 120) AS dob,
                TRIM(gender) AS gender,
                COALESCE(NULLIF(address, ''), 'n/a') AS address,
                TRIM(UPPER(LEFT(city,1)) + LOWER(SUBSTRING(city, 2, LEN(city)))) AS city,
                TRIM(UPPER(LEFT(state,1)) + LOWER(SUBSTRING(state, 2, LEN(state)))) AS state,
                TRIM(postal_code) AS postal_code,
                CASE 
                    WHEN phone_number = 'nan' OR phone_number IS NULL THEN 'n/a'
                    WHEN phone_number NOT LIKE '(%)%' THEN 
                        CONCAT('(', SUBSTRING(phone_number, 1, 3), ')', SUBSTRING(phone_number, 4, 3), '-', SUBSTRING(phone_number, 7, 4))
                    ELSE phone_number
                END AS phone_number,
                COALESCE(NULLIF(email, ''), 'n/a') AS email,
                COALESCE(NULLIF(insurance_provider, ''), 'n/a') AS insurance_provider,
                TRY_CAST(insurance_policy_number AS INT) AS insurance_policy_number,
                blood_type,
                allergies,
                medications,
                diagnosis,
                TRY_CONVERT(DATE, admission_date, 120) AS admission_date,
                TRY_CONVERT(DATE, discharge_date, 120) AS discharge_date,
                emergency_contact_name,
                emergency_contact_phone,
                emergency_contact_relationship,
                TRY_CONVERT(DATE, insurance_expiration_date, 120) AS insurance_expiration_date,
                TRY_CAST(blood_pressure AS DECIMAL(6,4)) AS blood_pressure,
                TRY_CAST(heart_rate AS DECIMAL(6,4)) AS heart_rate,
                TRY_CAST(weight AS DECIMAL(6,4)) AS weight,
                TRY_CAST(height AS DECIMAL(6,4)) AS height,
                TRY_CAST(temperature AS DECIMAL(6,4)) AS temperature,
                ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY admission_date DESC) AS rn
            FROM [bronze].[patient_info]
            WHERE 
                CAST(DATEDIFF(year, TRY_CAST(dob AS DATE), GETDATE()) AS INT) <= 100 
                AND (admission_date <= discharge_date OR discharge_date IS NULL)
        )
        
        INSERT INTO silver.patient_info (
            patient_id, first_name, last_name, dob, gender, address, city, state, postal_code, 
            phone_number, email, insurance_provider, insurance_policy_number, blood_type, allergies, 
            medications, diagnosis, admission_date, discharge_date, emergency_contact_name, 
            emergency_contact_phone, emergency_contact_relationship, insurance_expiration_date, 
            blood_pressure, heart_rate, weight, height, temperature
        )
        SELECT * FROM RankedPatients WHERE rn = 1;

        -- ✅ LOADING DOCTOR INFORMATION
        PRINT '>> Inserting Data Into silver.doctor_info';
        INSERT INTO silver.doctor_info (
            doctor_id, first_name, last_name, phone_number, email
        )
        SELECT DISTINCT doctor_id, first_name, last_name, phone_number, email
        FROM [bronze].[doctor_info]
        WHERE doctor_id IS NOT NULL;

        -- ✅ LOADING NURSE INFORMATION
        PRINT '>> Inserting Data Into silver.nurses_info';
        INSERT INTO silver.nurses_info (
            nurse_id, first_name, last_name, phone_number, email
        )
        SELECT DISTINCT nurse_id, first_name, last_name, phone_number, email
        FROM [bronze].[nurses_info];

        -- ✅ LOADING BILLING INFORMATION
        PRINT '>> Inserting Data Into silver.billing_info';
        INSERT INTO silver.billing_info (
            patient_id, total_amount, amount_paid, billing_date, due_date, payment_status, insurance_coverage
        )
        SELECT patient_id, total_amount, amount_paid, billing_date, due_date, payment_status, insurance_coverage
        FROM [bronze].[billing_info];

        -- ✅ LOADING INSURANCE INFORMATION
        PRINT '>> Inserting Data Into silver.insurance_info';
        INSERT INTO silver.insurance_info (
            patient_id, insurance_provider, policy_number, coverage_start_date, coverage_end_date
        )
        SELECT patient_id, insurance_provider, policy_number, coverage_start_date, coverage_end_date
        FROM [bronze].[insurance_info];

        -- ✅ LOADING ROOM INFORMATION
        PRINT '>> Updating Room Information';
        BEGIN TRANSACTION;
        UPDATE [bronze].[rooms_info]
        SET room_type = CASE 
            WHEN room_number % 3 = 0 THEN 'Single'
            WHEN room_number % 3 = 1 THEN 'Double'
            ELSE 'Suite'
        END;

        UPDATE [bronze].[rooms_info]
        SET capacity = CASE 
            WHEN room_number % 3 = 0 THEN '1'
            WHEN room_number % 3 = 1 THEN '2'
            ELSE '4'
        END;

        UPDATE [bronze].[rooms_info]
        SET current_occupancy = (
            SELECT COUNT(*)
            FROM [bronze].[patient_info] a
            WHERE a.room_number = [bronze].[rooms_info].room_number
            AND GETDATE() BETWEEN a.admission_date AND ISNULL(a.discharge_date, GETDATE() + 1) 
        );
        COMMIT;
        
        PRINT '>> Inserting Data Into silver.rooms_info';
        INSERT INTO silver.rooms_info (
            room_number, room_type, capacity, current_occupancy, is_available
        )
        SELECT * FROM [bronze].[rooms_info];
        
        PRINT '✅ Data successfully loaded into the Silver Layer';
    END TRY
    BEGIN CATCH
        SET @batch_end_time = GETDATE();
        PRINT '❌ ERROR OCCURRED DURING DATA LOAD';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '================================================';
    END CATCH
END;
