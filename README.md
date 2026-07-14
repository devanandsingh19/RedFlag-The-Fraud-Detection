# RedFlag - SQL Fraud Detection Engine

## Overview

RedFlag is a SQL-based fraud detection project developed using MySQL. The project analyzes a dataset of **200,000 simulated financial transactions** to identify various fraud patterns commonly encountered in digital payment systems.

The objective is to detect suspicious user behavior using only SQL, without relying on Python, machine learning, or external APIs.

---

## Dataset

- **Database:** MySQL
- **Records:** 200,000 Transactions
- **Users:** ~14,700
- **Time Period:** January 2024 – June 2024
- **Transaction Types:** CREDIT, DEBIT, REFUND
- **Additional Fields:**
  - User ID
  - Merchant ID
  - Amount
  - Transaction Time
  - Status
  - Payment Mode
  - City

---

## Fraud Patterns Implemented

### Tier 1

- Velocity Fraud
- Round Amount Clustering
- Card Testing
- Failed-Then-Succeeded Transactions
- Odd Hour Concentration

### Tier 2

- Mule Accounts
- Refund Abuse
- Merchant Collusion
- Just-Under-Threshold Transactions
- Dormant-Then-Active Accounts

### Tier 3

- Velocity Spike
- Geographic Impossibility

---

## SQL Concepts Used

- SELECT
- WHERE
- GROUP BY
- HAVING
- ORDER BY
- Aggregate Functions
- CASE WHEN
- JOIN
- Common Table Expressions (CTEs)
- Subqueries
- Correlated Subqueries
- Window Functions
  - ROW_NUMBER()
  - LAG()
  - LEAD()
- TIMESTAMPDIFF()
- DATE Functions

---

## Project Structure

```
RedFlag/
│
├── RedFlag_DevAnandSingh.sql      # Complete SQL solution
├── redflag_transactions.sql       # Dataset
└── README.md
```

---

## How to Run

### 1. Create a MySQL database

```sql
CREATE DATABASE redflag;
USE redflag;
```

### 2. Import the dataset

```sql
SOURCE redflag_transactions.sql;
```

### 3. Execute the solution

```sql
SOURCE RedFlag_DevAnandSingh.sql;
```

---

## Sample Fraud Detection Logic

### Velocity Fraud

Detect users performing **30 or more transactions in a single day.**

### Card Testing

Identify users performing **30 or more transactions below ₹10 in one day.**

### Merchant Collusion

Detect merchants where the **top five users contribute more than 60% of the merchant's transaction value.**

### Geographic Impossibility

Identify users transacting from **different cities within 60 minutes**, indicating possible account compromise.

---

## Skills Demonstrated

- SQL Query Writing
- Fraud Detection Analytics
- Financial Transaction Analysis
- Data Aggregation
- Window Functions
- Analytical SQL
- Problem Solving
- Query Optimization

---

## Tools Used

- MySQL 8.0
- MySQL Workbench

---

## Learning Outcomes

Through this project, I gained practical experience in:

- Detecting fraud using SQL
- Writing complex analytical queries
- Using CTEs and Window Functions
- Solving real-world business problems with relational databases
- Analyzing large datasets efficiently

---

## Author

**Dev Anand Singh**

GitHub: https://github.com/<your-github-username>

LinkedIn: https://linkedin.com/in/<your-linkedin-profile>

---

## License

This project is created for educational purposes as part of the **Unlox Academy Minor Project**.
