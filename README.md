# Oracle HCM Goal Detailed Report

## Overview

This repository contains the SQL query and documentation for a **BI Publisher (BIP) report developed in Oracle HCM Cloud** to extract detailed employee goal and goal plan information.

The report provides a comprehensive view of employee goals including goal status, goal plan submission status, progress tracking, manager hierarchy, and organizational details.

This solution demonstrates advanced SQL reporting using Oracle HCM Goal Management data structures.

---

## Technology Stack

* Oracle HCM Cloud
* Oracle BI Publisher (BIP)
* Oracle SQL

---

## Report Objective

The objective of this report is to provide HR teams and managers with **complete visibility into employee goals and goal plan progress**.

The report helps track:

* Goal plan submission status
* Total number of goals
* Individual goal status and progress
* Employee and assignment details
* Manager hierarchy (Direct and Matrix)
* Organizational structure

---

## Key Data Extracted

### Employee Information

* Employee Name
* Person Number
* Assignment Number
* Assignment Status
* Person Type
* Work Email

---

### Goal Plan Details

* Review Period Name
* Goal Plan Status (Submitted / Not Submitted)
* Total Goals Count

---

### Goal Details

* Goal Name
* Goal Description
* Goal Status
* Goal Start Date
* Target Completion Date
* Goal Completion Percentage

---

### Organizational Information

* Business Unit
* Department
* Legal Employer
* Location
* Country
* Business Group
* World Area

---

### Job Information

* Job Name
* Position Name
* Contributor Type
* Contributor Level
* Organization Level

---

### Manager Hierarchy

* Direct Line Manager Name & ID
* Matrix Manager Name & ID
* Manager Email Addresses

---

## Oracle HCM Tables Used

### Goal Management Tables

* HRG_GOALS
* HRG_GOAL_PLAN_GOALS
* HRG_GOAL_PLANS_VL
* HRG_GOAL_PLN_ASSIGNMENTS

---

### Employee Core Tables

* PER_ALL_PEOPLE_F
* PER_PERSON_NAMES_F
* PER_ALL_ASSIGNMENTS_M
* PER_PERIODS_OF_SERVICE

---

### Manager Hierarchy Tables

* PER_ASSIGNMENT_SUPERVISORS_F

---

### Organizational Tables

* HR_ALL_ORGANIZATION_UNITS
* HR_LOCATIONS_ALL
* PER_JOBS_F_VL
* HR_ALL_POSITIONS_F_VL

---

### Supporting Tables

* PER_EMAIL_ADDRESSES
* FND_LOOKUP_VALUES_VL
* FF_USER_TABLES_VL
* FF_USER_ROWS_VL

---

## Query Logic Highlights

### Goal Plan Status

The report determines whether a goal plan is submitted using:

* Count of active goals linked to the goal plan
* If count > 0 → **SUBMITTED**
* Else → **NOT SUBMITTED**

---

### Goal Count

The total number of goals is calculated using:

* HRG_GOALS
* HRG_GOAL_PLAN_GOALS

---

### Goal Status Decoding

Goal status is converted into readable format using:

HRG_GOAL_STATUS lookup

---

### Manager Hierarchy

Two types of managers are retrieved:

* **Line Manager** (Direct Manager)
* **Functional Manager** (Matrix Manager)

Using:

PER_ASSIGNMENT_SUPERVISORS_F

---

### Organizational Mapping

The query uses a **User Defined Table (UDT)** to derive:

* Business Group
* Platform
* Business Unit

---

### Security

The report uses:

PER_PERSON_SECURED_LIST_V

to ensure that users can only access data based on their security roles.

---

## Key Features

* Provides complete visibility into employee goals
* Tracks goal plan submission status
* Displays goal-level details and progress
* Includes both direct and matrix manager hierarchy
* Integrates employee, assignment, and organizational data
* Uses lookup decoding for meaningful values
* Supports parameter-driven filtering

---

## Repository Structure

```id="k2n4xm"
oracle-hcm-goal-detailed-report
│
├── README.md
└── goal_detailed_report.sql
```

---

## Parameters Supported

The report supports dynamic filtering using parameters such as:

* Review Period Name
* Employee Name
* Person Number
* Assignment Status
* Business Unit
* Legal Employer
* Department
* Manager Name

---

## Use Cases

This report can be used by:

* HR Business Partners
* Goal Management Teams
* Managers tracking employee goals
* HR Leadership

---

## Learning Outcomes

Developing this report required understanding of:

* Oracle HCM Goal Management data model
* Goal plan and goal relationships
* Manager hierarchy structure
* BI Publisher reporting
* Oracle HCM security model
* SQL optimization techniques

---

## Author

Saurabh Mharolkar
Oracle HCM Developer

---

## License

This project is licensed under the MIT License.

