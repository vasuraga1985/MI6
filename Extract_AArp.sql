--*****************************************************************************************************
--* Script Name : extract_aarp.sql
--*
--* Description : Script to extract data into a file in S3 for AARP Monthly extract
--*
--* DATE         USER               VERSION  COMMENTS
--* -----------  ----------         -------  -----------------------------------------------------------------
--* 12-Nov-2024  SOUMI SAHA          1.0      Created the script
--* 04-Dec-2024  SOUMI SAHA          1.1      Updated the script to use mart views instead of tables and added conditiond for f_txn_header
--* 06-Feb-2025  DASARI SRAVANTHI    1.2      Updated the script for city and state fields
--* 10-Mar-2025  SOUMI SAHA          1.3      Updated the script for changes in first_name and last_name fields
--*****************************************************************************************************

SELECT DISTINCT
si.cs_core_id AS IndividualID,
INITCAP(si.first_name) AS FirstName,
INITCAP(si.last_name) AS LastName,
lpc.addr_line_1 AS AddressLn1,
lpc.addr_line_2 AS AddressLn2,
/*lpc.city AS City,
lpc.state_province_name AS State,*/
lpc.locality1 AS City,
lpc.region1 AS State,
lpc.postal_code AS ZipCode
FROM
{tenant}.adhoc.f_txn_header_vw fth
INNER JOIN {tenant}.adhoc.xref_profile_coreid_vw xpc
ON fth.profile_id = xpc.profile_id
INNER JOIN {tenant}.adhoc.sum_individual_vw si
ON xpc.cs_core_id = si.cs_core_id
INNER JOIN {tenant}.adhoc.f_txn_discount_vw ftd
ON fth.txn_id = ftd.txn_id
INNER JOIN {tenant}.adhoc.lu_discount_type_vw ldt
ON ftd.discount_type_id = ldt.discount_type_id
INNER JOIN {tenant}.adhoc.lu_postal_contact_vw lpc
ON si.postal_contact_id = lpc.postal_contact_id
WHERE ldt.src_discount_type_code = 'NANA3LA' 
AND fth.txn_date >= '2022-02-01' and fth.txn_date <='2026-04-28'
AND fth.brand_org_code <> 'VALVOLINE' 
AND NVL(fth.invoice_credit_flag, 'N') <> 'Y'
AND fth.invoice_void_flag <> 'Y'  
AND fth.txn_type_code <> 'G'   
AND xpc.current_coreid_flag = 'Y' 
AND xpc.cs_core_id <> 'NOT_KEYED'
AND si.first_name IS NOT NULL
AND si.last_name IS NOT NULL
AND lpc.addr_line_1 IS NOT NULL
AND lpc.locality1 IS NOT NULL
AND lpc.region1 IS NOT NULL
AND lpc.postal_code IS NOT NULL;
