WITH
FUNC_REPORTS_TO_DATA
    AS
        (SELECT PASF.MANAGER_ASSIGNMENT_ID FUNC_REPORTS_TO_ASG_ID,
                PASF.MANAGER_ID,
                PN.FULL_NAME               FUNC_REPORTS_TO_NAME,
                PAAM_MGR.ASSIGNMENT_NUMBER FUNC_REPORTS_TO_ASG_NUMBER,
                PAPFS.PERSON_NUMBER        FUNC_REPORTS_TO_NUMBER,
                PASF.ASSIGNMENT_ID,
				PAST.USER_STATUS              ASSIGNMENT_STATUS_FN
           FROM PER_ASSIGNMENT_SUPERVISORS_F  PASF,
                PER_PERSON_NAMES_F            PN,
                PER_ALL_PEOPLE_F              PAPFS,
                PER_ALL_ASSIGNMENTS_M         PAAM_MGR,
				PER_ASSIGNMENT_STATUS_TYPES_VL  PAST
          WHERE     1 = 1                 
                AND PN.NAME_TYPE = 'GLOBAL'
                AND TRUNC (SYSDATE) BETWEEN PN.EFFECTIVE_START_DATE AND PN.EFFECTIVE_END_DATE
                AND PN.PERSON_ID = PASF.MANAGER_ID
                AND PAPFS.PERSON_ID = PASF.MANAGER_ID
                AND TRUNC (SYSDATE) BETWEEN PAPFS.EFFECTIVE_START_DATE AND PAPFS.EFFECTIVE_END_DATE
                AND PAAM_MGR.PERSON_ID = PASF.MANAGER_ID
                AND PAAM_MGR.ASSIGNMENT_ID = PASF.MANAGER_ASSIGNMENT_ID
                AND TRUNC (SYSDATE) BETWEEN PAAM_MGR.EFFECTIVE_START_DATE AND PAAM_MGR.EFFECTIVE_END_DATE
                AND TRUNC (SYSDATE) BETWEEN PASF.EFFECTIVE_START_DATE AND PASF.EFFECTIVE_END_DATE
                AND PAAM_MGR.EFFECTIVE_LATEST_CHANGE = 'Y'
                AND PAAM_MGR.ASSIGNMENT_TYPE = 'E'
                AND PAAM_MGR.PRIMARY_FLAG = 'Y'
                AND PASF.MANAGER_TYPE = 'FUNC_REPORT'
				AND PAAM_MGR.ASSIGNMENT_STATUS_TYPE_ID = PAST.ASSIGNMENT_STATUS_TYPE_ID
				),
    REPORTS_TO_DATA  
    AS
        (SELECT PASF.MANAGER_ASSIGNMENT_ID REPORTS_TO_ASG_ID,
                PASF.MANAGER_ID,
                PN.FULL_NAME               REPORTS_TO_NAME,
                PAAM_MGR.ASSIGNMENT_NUMBER REPORTS_TO_ASG_NUMBER,
                PAPFS.PERSON_NUMBER        REPORTS_TO_NUMBER,
                PASF.ASSIGNMENT_ID,
				PAST.USER_STATUS              ASSIGNMENT_STATUS_LN
           FROM PER_ASSIGNMENT_SUPERVISORS_F  PASF,
                PER_PERSON_NAMES_F            PN,
                PER_ALL_PEOPLE_F              PAPFS,
                PER_ALL_ASSIGNMENTS_M         PAAM_MGR,
				PER_ASSIGNMENT_STATUS_TYPES_VL  PAST
          WHERE     1 = 1                 
                AND PN.NAME_TYPE = 'GLOBAL'
                AND TRUNC (SYSDATE) BETWEEN PN.EFFECTIVE_START_DATE AND PN.EFFECTIVE_END_DATE
                AND PN.PERSON_ID = PASF.MANAGER_ID
                AND PAPFS.PERSON_ID = PASF.MANAGER_ID
                AND TRUNC (SYSDATE) BETWEEN PAPFS.EFFECTIVE_START_DATE AND PAPFS.EFFECTIVE_END_DATE
                AND PAAM_MGR.PERSON_ID = PASF.MANAGER_ID
                AND PAAM_MGR.ASSIGNMENT_ID = PASF.MANAGER_ASSIGNMENT_ID
                AND TRUNC (SYSDATE) BETWEEN PAAM_MGR.EFFECTIVE_START_DATE AND PAAM_MGR.EFFECTIVE_END_DATE
                AND TRUNC (SYSDATE) BETWEEN PASF.EFFECTIVE_START_DATE AND PASF.EFFECTIVE_END_DATE
				AND PAAM_MGR.EFFECTIVE_LATEST_CHANGE = 'Y'
                AND PAAM_MGR.ASSIGNMENT_TYPE = 'E'
                AND PAAM_MGR.PRIMARY_FLAG = 'Y'
                AND PASF.MANAGER_TYPE = 'LINE_MANAGER'
				AND PAAM_MGR.ASSIGNMENT_STATUS_TYPE_ID = PAST.ASSIGNMENT_STATUS_TYPE_ID
				)  
  SELECT ((ROWNUM - MOD (ROWNUM, 50000)) / 50000) + 1
             PH_ROWNUM,
         PPNF.FULL_NAME
             EMPLOYEE_NAME,
         PAPF.PERSON_NUMBER
             EMPLOYEE_ID,
         PAAM.ASSIGNMENT_NUMBER,
         HRPL.REVIEW_PERIOD_NAME,
         (CASE
              WHEN (SELECT COUNT (*)
                      FROM HRG_GOALS HGC, HRG_GOAL_PLAN_GOALS HGPGC
                     WHERE     HGC.PERSON_ID = HG.PERSON_ID
                           AND HGC.GOAL_ID = HGPGC.GOAL_ID
                           AND HGPGC.GOAL_PLAN_ID = HGPL.GOAL_PLAN_ID
                           AND HGC.STATUS_CODE NOT IN ('DELETED', 'CANCEL')) >
                   0
              THEN
                  'SUBMITTED'
              ELSE
                  'NOT SUBMITTED'
          END)
             AS GOAL_PLAN_STATUS,
         (SELECT COUNT (*)
            FROM HRG_GOALS HGC, HRG_GOAL_PLAN_GOALS HGPGC
           WHERE     HGC.PERSON_ID = HG.PERSON_ID
                 AND HGC.GOAL_ID = HGPGC.GOAL_ID
                 AND HGPGC.GOAL_PLAN_ID = HGPL.GOAL_PLAN_ID --AND HGC.STATUS_CODE NOT IN ('DELETED','CANCEL')
                                                           )
             GOALS_COUNT,
         PER_EXTRACT_UTILITY.GET_DECODED_LOOKUP ('HRG_GOAL_STATUS',
                                                 HG.STATUS_CODE)
             GOAL_STATUS,
         TO_CHAR (HG.START_DATE, 'DD-MON-YYYY', 'NLS_DATE_LANGUAGE = AMERICAN')
             AS GOAL_START_DATE,
         TO_CHAR (HG.TARGET_COMPLETION_DATE,
                  'DD-MON-YYYY',
                  'NLS_DATE_LANGUAGE = AMERICAN')
             AS GOAL_TARGET_COMPLETION_DATE,
         HG.GOAL_NAME,
		 HG.DESCRIPTION, 
         HG.PERCENT_COMPLETE_CODE
             GOAL_COMPLETION,
         BU.NAME
             BU_UNIT,
         HAOU.NAME
             EMPLOYEE_DEPARTMENT,
         HLA.LOCATION_NAME
             EMPLOYEE_LOCATION,
         LE.NAME
             EMPLOYEE_LEGAL_EMPLOYER,
         (SELECT GEOGRAPHY_NAME
            FROM HZ_GEOGRAPHIES
           WHERE     GEOGRAPHY_TYPE = 'COUNTRY'
                 AND GEOGRAPHY_CODE = PPOS.LEGISLATION_CODE
                 AND ROWNUM = 1)
             AS LEGAL_EMPLOYER_COUNTRY,
   
         PJF.NAME
             JOB_NAME,
         PAAM.ASSIGNMENT_NAME
             ASSIGNMENT_NAME,  
         PJF.MANAGER_LEVEL
             CONTRIBUTOR_TYPE,     
         PJF.ATTRIBUTE13
             CONTRIBUTOR_TYPE_LEVEL, 
        
         PJF.APPROVAL_AUTHORITY
             ORG_LEVEL,                                    
         HAPF.NAME
             POS_NAME,
         PASTT.USER_STATUS
             ASSIGNMENT_STATUS,
         (SELECT MEANING
            FROM FND_LOOKUP_VALUES_VL
           WHERE     LOOKUP_CODE = PPOS.PERIOD_TYPE
                 AND LOOKUP_TYPE = 'PER_PERIOD_TYPE'
                 AND ROWNUM = 1)
             PERSON_TYPE,
         PER_EXTRACT_UTILITY.GET_DECODED_LOOKUP ('EMP_CAT',
                                                 PAAM.EMPLOYMENT_CATEGORY)
             ASSIGNMENT_CATEGORY,
         DECODE (PAAM.HOURLY_SALARIED_CODE,  'S', 'SALARIED',  'H', 'HOURLY')
             HOURLY_PAID_OR_SALARIED,
         DECODE (PAAM.PRIMARY_FLAG,  'Y', 'YES',  'N', 'NO')
             PRIMARY_WORK_RELATION_FLAG,
         TO_CHAR (PPOS.DATE_START,
                  'DD-MON-YYYY',
                  'NLS_DATE_LANGUAGE = AMERICAN')
             HIRE_DATE,
         (SELECT TO_CHAR (MIN (PPOS1.DATE_START),
                          'DD-MON-YYYY',
                          'NLS_DATE_LANGUAGE = AMERICAN')
            FROM PER_PERIODS_OF_SERVICE PPOS1
           WHERE     PPOS1.PERSON_ID = PAPF.PERSON_ID
                 AND PPOS1.PERIOD_TYPE = PPOS.PERIOD_TYPE)
             ENTERPRISE_HIRE_DATE,
         TO_CHAR (PPOS.ADJUSTED_SVC_DATE,
                  'DD-MON-YYYY',
                  'NLS_DATE_LANGUAGE = AMERICAN')
             LATEST_START_DATE,
       
         PEAW.EMAIL_ADDRESS
             EMPLOYEE_WORK_EMAIL,                                     
         ORG_UDT.BUSINESS_GROUP,                                      
         (SELECT FF_USER_TABLES_PKG.GET_TABLE_VALUE_ENT (
                     1,
                     SYSDATE,
                     'EMR_WORLD_AREAS',
                     'WORLD_AREA',
                     (SELECT GEOGRAPHY_NAME
                        FROM HZ_GEOGRAPHIES
                       WHERE     GEOGRAPHY_TYPE = 'COUNTRY'
                             AND GEOGRAPHY_CODE = PAAM.LEGISLATION_CODE
                             AND TRUNC (SYSDATE) BETWEEN TRUNC (START_DATE)
                                                     AND TRUNC (END_DATE)
                             AND ROWNUM = 1))
            FROM DUAL)
             WORLD_AREA,                                              
		FUNC_REPORTS_TO.FUNC_REPORTS_TO_NAME MATRIX_MGR_NAME,
		FUNC_REPORTS_TO.FUNC_REPORTS_TO_NUMBER MATRIX_MGR_ID,
		REPORTS_TO.REPORTS_TO_NAME DIRECT_LINE_MGR_NAME, 
        REPORTS_TO.REPORTS_TO_NUMBER DIRECT_LINE_MGR_ID,
	    (SELECT (PEAW_FUN_MANAGER.EMAIL_ADDRESS)
            FROM PER_EMAIL_ADDRESSES         PEAW_FUN_MANAGER,
                 PER_ASSIGNMENT_SUPERVISORS_F PASF
           WHERE     PASF.ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID
                 AND PASF.MANAGER_TYPE = 'FUNC_REPORT'
                 --AND PASF.PRIMARY_FLAG = 'Y'
                 AND PASF.MANAGER_ID = PEAW_FUN_MANAGER.PERSON_ID(+)
				 AND TRUNC (SYSDATE) BETWEEN PASF.EFFECTIVE_START_DATE
                                               AND PASF.EFFECTIVE_END_DATE
                 AND PEAW_FUN_MANAGER.EMAIL_TYPE(+) = 'W1'
                 AND TRUNC (SYSDATE) BETWEEN PEAW_FUN_MANAGER.DATE_FROM(+)
                                 AND COALESCE (
                                         PEAW_FUN_MANAGER.DATE_TO(+),
                                         TO_DATE ('4712/12/31', 'YYYY/MM/DD'))
                 AND ROWNUM = 1)
             MATRIX_MGR_EMAIL, 
		 (SELECT (PEAW_LN_MANAGER.EMAIL_ADDRESS)
            FROM PER_EMAIL_ADDRESSES         PEAW_LN_MANAGER,
                 PER_ASSIGNMENT_SUPERVISORS_F PASF
           WHERE     PASF.ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID
                 AND PASF.MANAGER_TYPE = 'LINE_MANAGER'
                 --AND PASF.PRIMARY_FLAG = 'Y'
                 AND PASF.MANAGER_ID = PEAW_LN_MANAGER.PERSON_ID(+)
				 AND TRUNC (SYSDATE) BETWEEN PASF.EFFECTIVE_START_DATE
                                               AND PASF.EFFECTIVE_END_DATE
                 AND PEAW_LN_MANAGER.EMAIL_TYPE(+) = 'W1'
                 AND TRUNC (SYSDATE) BETWEEN PEAW_LN_MANAGER.DATE_FROM(+)
                                 AND COALESCE (
                                         PEAW_LN_MANAGER.DATE_TO(+),
                                         TO_DATE ('4712/12/31', 'YYYY/MM/DD'))
                 AND ROWNUM = 1)
             DIRECT_LINE_MNGR_WORK_EMAIL 
        
    FROM HRG_GOALS                     HG,
         HRG_GOAL_PLAN_GOALS           HGPG,
         HRG_GOAL_PLANS_VL             HGPL,
		 HRG_GOAL_PLN_ASSIGNMENTS      GPA, 
         HRT_REVIEW_PERIODS_VL         HRPL,
         PER_PERSON_SECURED_LIST_V     PAPF,
         PER_PERSON_NAMES_F            PPNF,
         PER_ALL_ASSIGNMENTS_M         PAAM,
         PER_PERIODS_OF_SERVICE        PPOS,
         PER_ASSIGNMENT_STATUS_TYPES_TL PASTT,
         PER_EMAIL_ADDRESSES           PEAW,
         HR_ALL_ORGANIZATION_UNITS     LE,
         HR_ALL_ORGANIZATION_UNITS     BU,
         PER_JOBS_F_VL                 PJF, 
         HR_ALL_POSITIONS_F_VL         HAPF,
         HR_ALL_ORGANIZATION_UNITS     HAOU,
         HR_LOCATIONS_ALL              HLA,
        
         HR_ALL_ORGANIZATION_UNITS_F_VL HAOUFVL_BU,
         (SELECT FUCI_PLAT.VALUE PLATFORM,
                 FUCI_BG.VALUE BUSINESS_GROUP,
                 FUR.ROW_NAME  BUSINESS_UNIT
            FROM FUSION.FF_USER_TABLES_VL         FUT,
                 FUSION.FF_USER_ROWS_VL           FUR,
                 FUSION.FF_USER_COLUMNS_VL        FUC_PLAT,
                 FUSION.FF_USER_COLUMN_INSTANCES_F FUCI_PLAT,
                 FUSION.FF_USER_COLUMNS_VL        FUC_BG,
                 FUSION.FF_USER_COLUMN_INSTANCES_F FUCI_BG
           WHERE     1 = 1
                 AND UPPER (FUT.BASE_USER_TABLE_NAME) =
                     'UDT_NAME'
                 AND FUT.USER_TABLE_ID = FUR.USER_TABLE_ID
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (FUR.EFFECTIVE_START_DATE)
                                         AND TRUNC (FUR.EFFECTIVE_END_DATE)
                 AND FUT.USER_TABLE_ID = FUC_PLAT.USER_TABLE_ID
                 AND FUC_PLAT.USER_COLUMN_NAME = 'Platform'
                 AND FUC_PLAT.USER_COLUMN_ID = FUCI_PLAT.USER_COLUMN_ID
                 AND FUR.USER_ROW_ID = FUCI_PLAT.USER_ROW_ID(+)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                                 FUCI_PLAT.EFFECTIVE_START_DATE(+))
                                         AND TRUNC (
                                                 FUCI_PLAT.EFFECTIVE_END_DATE(+))
                 AND FUT.USER_TABLE_ID = FUC_BG.USER_TABLE_ID
                 AND FUC_BG.USER_COLUMN_NAME = 'Business_Group'
                 AND FUC_BG.USER_COLUMN_ID = FUCI_BG.USER_COLUMN_ID
                 AND FUR.USER_ROW_ID = FUCI_BG.USER_ROW_ID
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                                 FUCI_BG.EFFECTIVE_START_DATE(+))
                                         AND TRUNC (FUCI_BG.EFFECTIVE_END_DATE))
         ORG_UDT,
    
		 FUNC_REPORTS_TO_DATA FUNC_REPORTS_TO, 		
		 REPORTS_TO_DATA  REPORTS_TO 
   WHERE     1 = 1
         AND HG.GOAL_ID = HGPG.GOAL_ID
         AND HGPG.GOAL_PLAN_ID = HGPL.GOAL_PLAN_ID
         AND HG.GOAL_VERSION_TYPE_CODE = 'ACTIVE'
         AND HGPG.REVIEW_PERIOD_ID = HRPL.REVIEW_PERIOD_ID
         
		 AND HG.ASSIGNMENT_ID=PAAM.ASSIGNMENT_ID 
		 AND GPA.REVIEW_PERIOD_ID = HRPL.REVIEW_PERIOD_ID           
         AND GPA.GOAL_PLAN_ID = HGPL.GOAL_PLAN_ID 
		 AND PAAM.ASSIGNMENT_ID = GPA.ASSIGNMENT_ID
         AND PAPF.PERSON_ID = PAAM.PERSON_ID
         AND PAAM.PERIOD_OF_SERVICE_ID = PPOS.PERIOD_OF_SERVICE_ID
         AND PAAM.ASSIGNMENT_STATUS_TYPE_ID =
             PASTT.ASSIGNMENT_STATUS_TYPE_ID(+)
         AND PAAM.BUSINESS_UNIT_ID = BU.ORGANIZATION_ID
         AND PAAM.LEGAL_ENTITY_ID = LE.ORGANIZATION_ID
         AND PAPF.PERSON_ID = PPNF.PERSON_ID
         AND PAAM.JOB_ID = PJF.JOB_ID(+)
         AND PAAM.POSITION_ID = HAPF.POSITION_ID(+)
         AND PAAM.ORGANIZATION_ID = HAOU.ORGANIZATION_ID(+)
         AND PAAM.LOCATION_ID = HLA.LOCATION_ID(+)
        
         AND PPNF.NAME_TYPE = 'GLOBAL'
       
         AND PAAM.ASSIGNMENT_TYPE = 'E'
         AND PASTT.LANGUAGE = 'US'
         AND PAAM.BUSINESS_UNIT_ID = HAOUFVL_BU.ORGANIZATION_ID
		 AND PAAM.ASSIGNMENT_ID =FUNC_REPORTS_TO.ASSIGNMENT_ID (+)
         AND PAAM.ASSIGNMENT_ID = REPORTS_TO.ASSIGNMENT_ID (+)
         AND TRUNC (SYSDATE) BETWEEN HAOUFVL_BU.EFFECTIVE_START_DATE
                                 AND HAOUFVL_BU.EFFECTIVE_END_DATE
         AND UPPER (HAOUFVL_BU.NAME) = UPPER (ORG_UDT.BUSINESS_UNIT(+))
         
         AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                 AND TRUNC (PAPF.EFFECTIVE_END_DATE)
     
         AND TRUNC (SYSDATE) BETWEEN TRUNC (PPNF.EFFECTIVE_START_DATE)
                                 AND TRUNC (PPNF.EFFECTIVE_END_DATE)
         AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAM.EFFECTIVE_START_DATE)
                                 AND TRUNC (PAAM.EFFECTIVE_END_DATE)
       
         AND TRUNC (SYSDATE) BETWEEN TRUNC (LE.EFFECTIVE_START_DATE)
                                 AND TRUNC (LE.EFFECTIVE_END_DATE)
         AND TRUNC (SYSDATE) BETWEEN TRUNC (PJF.EFFECTIVE_START_DATE(+))
                                 AND TRUNC (PJF.EFFECTIVE_END_DATE(+))
         AND TRUNC (SYSDATE) BETWEEN TRUNC (HAPF.EFFECTIVE_START_DATE(+))
                                 AND TRUNC (HAPF.EFFECTIVE_END_DATE(+))
         AND TRUNC (SYSDATE) BETWEEN TRUNC (HAOU.EFFECTIVE_START_DATE(+))
                                 AND TRUNC (HAOU.EFFECTIVE_END_DATE(+))
         AND TRUNC (SYSDATE) BETWEEN TRUNC (HLA.EFFECTIVE_START_DATE(+))
                                 AND TRUNC (HLA.EFFECTIVE_END_DATE(+))
         AND PAPF.PERSON_ID = PEAW.PERSON_ID(+)
         AND PEAW.EMAIL_TYPE(+) = 'W1'
         AND TRUNC (SYSDATE) BETWEEN PEAW.DATE_FROM(+)
                                 AND NVL (PEAW.DATE_TO(+), TRUNC (SYSDATE))
      
         AND (   HRPL.REVIEW_PERIOD_NAME IN (:REVIEW_PERIOD_NAME)
              OR (LEAST (:REVIEW_PERIOD_NAME) IS NULL))
         AND (   PPNF.PERSON_ID IN (:PERSON_NAME)
              OR (LEAST (:PERSON_NAME) IS NULL))
         AND (   PAPF.PERSON_ID IN (:PERSON_NUMBER)
              OR (LEAST (:PERSON_NUMBER) IS NULL))
         AND (   PASTT.USER_STATUS IN (:ASSIGNMENT_STATUS)
              OR (LEAST (:ASSIGNMENT_STATUS) IS NULL))
         AND (PAAM.BUSINESS_UNIT_ID IN (:BU_UNIT) OR (LEAST (:BU_UNIT) IS NULL))
         AND (   PAAM.LEGAL_ENTITY_ID IN (:EMPLOYEE_LEGAL_EMPLOYER)
              OR (LEAST (:EMPLOYEE_LEGAL_EMPLOYER) IS NULL))
         AND (   PAAM.ORGANIZATION_ID IN (:EMPLOYEE_DEPARTMENT)
              OR (LEAST (:EMPLOYEE_DEPARTMENT) IS NULL))
         AND (   REPORTS_TO.MANAGER_ID IN (:MANAGER_NAME)
              OR (LEAST (:MANAGER_NAME) IS NULL))
ORDER BY PPNF.FULL_NAME, HRPL.REVIEW_PERIOD_NAME