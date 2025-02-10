/*
-- =============================================================
-- Healthcare Management System (HMS) - Bronze Layer Loading Procedure
-- =============================================================
-- PURPOSE:
-- This stored procedure loads the BRONZE layer in the ETL pipeline.
-- It performs the following steps:
-- 1. Loads raw patient data from an external CSV file.
-- 2. Extracts doctor and nurse IDs from the source table.
-- 3. Stores raw data in the BRONZE layer without transformations.
-- 4. Handles errors using TRY...CATCH for logging failures.
-- =============================================================
-- ⚠ WARNINGS:
-- - This procedure TRUNCATES all Bronze tables before loading (DATA LOSS RISK).
-- - BULK INSERT expects a correctly formatted CSV file in the specified path.
-- - Only doctor_id and nurse_id are extracted (names are generated later).
-- - This procedure is designed for DEVELOPMENT and TESTING environments.
-- =============================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
     DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
     
	 BEGIN TRY
	     SET @batch_start_time = GETDATE();
         PRINT '===================================';
         PRINT '        Loading Bronze Layer       ';
	     PRINT '===================================';
	     
	     -- =============================================================
	     -- 1️⃣ Load Patient Data from CSV File
	     -- =============================================================
	     PRINT '-------------------------------------';
	     PRINT '  Loading Patient Table ';
	     PRINT '-------------------------------------';
		 
	     SET @start_time = GETDATE();
	     PRINT '>> Truncating Table: bronze.patient_info';
	     TRUNCATE TABLE bronze.patient_info;

         PRINT '>> Inserting Data Into: bronze.patient_info';
         BULK INSERT bronze.patient_info
         FROM 'C:\\Users\\User\\OneDrive\\Рабочий стол\\SQl-Warehouse Protfolio Porject\\Project\\ERP_MASTER.csv'
         WITH (
             FIRSTROW = 2,
             FIELDTERMINATOR = ',',
             TABLOCK 
         );

         SET @end_time = GETDATE();
		 PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		 PRINT '>> ----------------';
         SELECT COUNT(*) AS Patient_Record_Count FROM bronze.patient_info;

         -- =============================================================
	     -- 2️⃣ Load Doctors from Main Table (Only doctor_id)
	     -- =============================================================
	     PRINT '-------------------------------------';
	     PRINT '  Loading Doctor Table ';
	     PRINT '-------------------------------------';
		 
	     SET @start_time = GETDATE();
	     PRINT '>> Truncating Table: bronze.doctor_info';
	     TRUNCATE TABLE bronze.doctor_info;

         PRINT '>> Inserting Data Into: bronze.doctor_info';
         INSERT INTO bronze.doctor_info (doctor_id)
         SELECT DISTINCT doctor_id FROM [dbo].[ERP_Master_Patient]
         WHERE doctor_id IS NOT NULL;

         SET @end_time = GETDATE();
		 PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		 PRINT '>> ----------------';
         SELECT COUNT(*) AS Doctor_Record_Count FROM bronze.doctor_info;

         -- =============================================================
	     -- 3️⃣ Load Nurses from Main Table (Only nurse_id)
	     -- =============================================================
	     PRINT '-------------------------------------';
	     PRINT '  Loading Nurse Table ';
	     PRINT '-------------------------------------';
		 
	     SET @start_time = GETDATE();
	     PRINT '>> Truncating Table: bronze.nurses_info';
	     TRUNCATE TABLE bronze.nurses_info;

         PRINT '>> Inserting Data Into: bronze.nurses_info';
         INSERT INTO bronze.nurses_info (nurse_id)
         SELECT DISTINCT nurse_id FROM [dbo].[ERP_Master_Patient]
         WHERE nurse_id IS NOT NULL;

         SET @end_time = GETDATE();
		 PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		 PRINT '>> ----------------';
         SELECT COUNT(*) AS Nurse_Record_Count FROM bronze.nurses_info;

     END TRY

   BEGIN CATCH
        SET @batch_end_time = GETDATE();
        PRINT '================================================';
		PRINT ' ❌ ERROR OCCURRED DURING LOADING BRONZE LAYER ';
		PRINT '------------------------------------------------';
		PRINT ' 🔴 Error Message: ' + ERROR_MESSAGE();
		PRINT ' 🔴 Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT ' 🔴 Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '================================================';
   END CATCH
END;
GO

-- =============================================================
-- 🔥 END OF SCRIPT 🔥
-- =============================================================
-- ✅ This procedure is part of the ETL process (Bronze Layer).
-- ✅ Extracts raw data but does not clean or transform it.
-- ✅ The Silver layer will perform data validation and corrections.
-- =============================================================
