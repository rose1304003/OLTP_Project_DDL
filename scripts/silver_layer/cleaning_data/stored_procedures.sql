-- ==========================================
-- STORED PROCEDURE: Load Bronze to Silver Layer
-- ==========================================
CREATE OR ALTER PROCEDURE BRONZE.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '===================================';
        PRINT 'STARTING LOADING PROCESS FROM BRONZE TO SILVER';
        PRINT '===================================';
        
        -- WARNING: Ensure that the target tables exist before running this procedure.
        
        PRINT '-------------------------------------';
        PRINT 'Loading Patient table';
        PRINT '-------------------------------------';
        
        SET @start_time = GETDATE();
        PRINT '>> Extracting and Cleaning Data from Bronze Layer';
        
        -- Process Patient Data
        WITH RankedPatients AS (
            SELECT 
                patient_id,
                UPPER(LEFT(first_name, 1)) + LOWER(SUBSTRING(first_name, 2, LEN(first_name))) AS first_name,  
                UPPER(LEFT(last_name, 1)) + LOWER(SUBSTRING(last_name, 2, LEN(last_name))) AS last_name,  
                TRIM(dob) AS dob,
                TRIM(gender) AS gender,
                COALESCE(NULLIF(TRIM(address), ''), 'n/a') AS address,
                TRIM(UPPER(LEFT(city,1)) + LOWER(SUBSTRING(city, 2, LEN(city)))) AS city,
                TRIM(UPPER(LEFT(state,1)) + LOWER(SUBSTRING(state, 2, LEN(state)))) AS state,
                TRIM(postal_code) AS postal_code,
                CASE WHEN phone_number IS NULL OR phone_number = 'nan' THEN 'n/a'
                     ELSE phone_number
                END AS phone_number,
                COALESCE(email, 'n/a') AS email,
                COALESCE(insurance_provider, 'n/a') AS insurance_provider,
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
                TRIM(blood_pressure) AS blood_pressure,
                TRIM(heart_rate) AS heart_rate,
                TRIM(weight) AS weight,
                height,
                temperature,
                ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY admission_date DESC) AS rn
            FROM [bronze].[patient_info]
            WHERE CAST(DATEDIFF(year, TRY_CAST(dob AS DATE), GETDATE()) AS INT) <= 100 
              AND admission_date <= discharge_date
        )
        SELECT * FROM RankedPatients WHERE rn = 1;
    
    END TRY
    BEGIN CATCH
        SET @batch_end_time = GETDATE();
        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '================================================';
    END CATCH
END;

-- ==========================================
-- SELECT STATEMENTS FOR VERIFICATION
-- ==========================================
SELECT * FROM [dbo].[ERP_Master_Patient];
SELECT * FROM [bronze].[patient_info];

--==========================================================================================================
-- Billing Records Procedure: Loads billing information from patient data
--==========================================================================================================
CREATE OR ALTER PROCEDURE BRONZE.load_silver_BILLING AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '===================================';
        PRINT 'Loading Bronze Layer TO THE BILLING';
        PRINT '===================================';
        
        PRINT '>> Truncating Table: bronze.billing_info';
        IF OBJECT_ID('bronze.BILLING_info', 'U') IS NOT NULL
            TRUNCATE TABLE [bronze].[billing_info];
        
        PRINT '>> Inserting Billing Records';
        INSERT INTO [SQL_Project].[bronze].[billing_info] (patient_id, billing_date, due_date)
        SELECT 
            patient_id, 
            admission_date AS billing_date, 
            DATEADD(DAY, 30, discharge_date) AS due_date  -- Due 30 days after discharge
        FROM [SQL_Project].[bronze].[patient_info]
        WHERE admission_date <= discharge_date AND discharge_date IS NOT NULL;  -- Ensuring billing happens after discharge
    
    END TRY
    BEGIN CATCH
        SET @batch_end_time= GETDATE();
        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '================================================';
    END CATCH
END;

SELECT * FROM [bronze].[billing_info];

--==========================================================================================================
-- Assign Room to Patient Procedure: Finds an available room and updates the patient record
--==========================================================================================================
CREATE OR ALTER PROCEDURE BRONZE.AssignRoomToPatient @PatientID NVARCHAR(50) AS
BEGIN
    DECLARE @RoomID INT;
    BEGIN TRY
        PRINT '===================================';
        PRINT 'Assigning Room to Patient';
        PRINT '===================================';
        
        BEGIN TRANSACTION;
        -- Find the first available room
        SELECT TOP 1 @RoomID = room_number FROM bronze.rooms_info WHERE is_available = 'Available' ORDER BY room_number;
        
        IF @RoomID IS NULL
        BEGIN
            PRINT 'No available rooms at the moment.';
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- Assign room to patient
        UPDATE bronze.patient_info SET room_number = @RoomID WHERE patient_id = @PatientID;
        
        -- Mark room as occupied
        UPDATE bronze.rooms_info SET is_available = 'Occupied' WHERE room_number = @RoomID;
        
        COMMIT TRANSACTION;
        PRINT 'Room ' + CAST(@RoomID AS NVARCHAR) + ' assigned to patient ID ' + CAST(@PatientID AS NVARCHAR);
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING ROOM ASSIGNMENT';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT '================================================';
    END CATCH
END;

--==========================================================================================================
-- Discharge Patient Procedure: Updates the patient’s discharge date and marks the room available
--==========================================================================================================
CREATE OR ALTER PROCEDURE BRONZE.DischargePatient @PatientID NVARCHAR(50) AS
BEGIN
    DECLARE @RoomID INT;
    BEGIN TRY
        PRINT '===================================';
        PRINT 'Discharging Patient';
        PRINT '===================================';
        
        BEGIN TRANSACTION;
        -- Find patient's room
        SELECT @RoomID = room_number FROM bronze.patient_info WHERE patient_id = @PatientID AND discharge_date IS NULL;
        
        IF @RoomID IS NULL
        BEGIN
            PRINT 'No active patient found or patient already discharged.';
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- Update patient discharge date
        UPDATE bronze.patient_info SET discharge_date = GETDATE() WHERE patient_id = @PatientID;
        
        -- Mark room as available
        UPDATE bronze.rooms_info SET is_available = 'Available' WHERE room_number = @RoomID;
        
        COMMIT TRANSACTION;
        PRINT 'Patient discharged, room updated successfully.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING PATIENT DISCHARGE';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT '================================================';
    END CATCH
END;

CREATE OR ALTER PROCEDURE BRONZE.DischargePatientBilling 
       @PatientID NVARCHAR(50)
AS
BEGIN
     DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME 
	 BEGIN TRY
	 SET @batch_start_time = GETDATE();
	 PRINT '===================================';
     PRINT 'Loading Brozne Layer TO THE ROOM INFO';
	 PRINT '===================================';
	 
	 
	 PRINT'-------------------------------------';
	 PRINT'Loading Patient table TO ROOM INFO';
	 PRINT'-------------------------------------';

	 SET @start_time = GETDATE();
	 PRINT '>> Truncating Table: bronze.room_info';
     SET NOCOUNT ON;

-- Update discharge_date for the patient
UPDATE [bronze].[patient_info]
SET discharge_date = GETDATE()
WHERE patient_id = @PatientID AND discharge_date IS NULL;

-- Get the room_id assigned to the patient
DECLARE @BillingID INT;
SELECT @BillingID=billing_id FROM [bronze].[billing_info] WHERE patient_id = @PatientID;

-- Mark the payment_status 
UPDATE [bronze].[billing_info]
    SET payment_status = 
        CASE 
            WHEN amount_paid IS NULL OR amount_paid = 0 THEN 'Unpaid'
            WHEN amount_paid < total_amount THEN 'Partial'
            WHEN amount_paid >= total_amount THEN 'Paid'
            ELSE 'Unknown'
        END;
    PRINT 'Patient discharged and payment_status marked.';
END TRY
   BEGIN CATCH
        SET @batch_end_time= GETDATE()
        PRINT '================================================'
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Eror Message' + ERROR_MESSAGE();
		PRINT 'Error Message' +CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' +CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '================================================'
   END CATCH
END;
