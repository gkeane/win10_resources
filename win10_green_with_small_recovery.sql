-- Windows 10 Green Machines with Small Recovery Partition
-- This query returns Windows 10 systems that are marked as 'Capable' for upgrade (green)
-- and have a recovery partition size (from the CI-Recovery_Partition_size custom inventory item)
-- less than 2GB (2048 MB).
--
-- Usage:
-- 1. Log into your KACE SMA web interface
-- 2. Navigate to the SQL Query tool
-- 3. Copy and paste this script
-- 4. Execute the query to get the results

SELECT 
  MACHINE.NAME AS SYSTEM_NAME, 
  SYSTEM_DESCRIPTION, 
  MACHINE.IP, 
  MACHINE.MAC, 
  MACHINE.ID AS TOPIC_ID,
  CAST(MCI.STR_FIELD_VALUE AS FLOAT) AS RECOVERY_PARTITION_MB
FROM 
  MACHINE
LEFT JOIN 
  OSUPGRADE_READINESS ON OSUPGRADE_READINESS.ID = MACHINE.ID
LEFT JOIN 
  MACHINE_CUSTOM_INVENTORY MCI ON MCI.ID = MACHINE.ID
LEFT JOIN 
  SOFTWARE S ON S.ID = MCI.SOFTWARE_ID
WHERE 
  OS_NAME LIKE 'Microsoft Windows 10%' 
  AND OSUPGRADE_READINESS.STATUS = 'Capable'
  AND S.DISPLAY_NAME = 'CI-Recovery_Partition_size'
  AND CAST(MCI.STR_FIELD_VALUE AS FLOAT) < 2048 