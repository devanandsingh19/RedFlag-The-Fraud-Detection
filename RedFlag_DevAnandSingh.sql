-- =====================================================================
-- RedFlag — Fraud Detection Submission
-- Student: DEV ANAND SINGH | Batch: DA-DS-1
-- =====================================================================

use redflag;

-- ============================== P1 ===================================
-- PATTERN 1 · VELOCITY FRAUD
-- =====================================================================

SELECT user_id, DATE(txn_time) as txn_date, COUNT(*) as total_txn
FROM transactions
GROUP BY user_id, DATE(txn_time)
HAVING total_txn >= 30;

-- ============================== P2 ===================================
-- PATTERN 2 · ROUND-AMOUNT CLUSTERING
-- =====================================================================

SELECT user_id, COUNT(*) as round_txn
FROM transactions
WHERE amount in (100, 200, 500, 1000, 2000, 5000, 10000)
GROUP BY user_id
HAVING COUNT(*) >= 15;

-- ============================== P3 ===================================
-- PATTERN 3 · CARD TESTING
-- =====================================================================

SELECT user_id, DATE(txn_time) as txn_date, COUNT(*) as total_txn
FROM transactions
WHERE amount < 10
GROUP BY user_id, DATE(txn_time)
HAVING count(*) >= 30;

-- ============================== P4 ===================================
-- PATTERN 4 · FAILED-THEN-SUCCEEDED
-- =====================================================================

SELECT
    t1.user_id,
    COUNT(*) AS failed_success_pairs
FROM transactions t1
JOIN transactions t2
    ON t1.user_id = t2.user_id
   AND t2.txn_time = (
        SELECT MIN(t3.txn_time)
        FROM transactions t3
        WHERE t3.user_id = t1.user_id
          AND t3.txn_time > t1.txn_time
   )
WHERE t1.status = 'FAILED'
  AND t2.status = 'SUCCESS'
GROUP BY t1.user_id
HAVING COUNT(*) >= 20;

-- ============================== P5 ===================================
-- PATTERN 5 · ODD-HOUR CONCENTRATION
-- =====================================================================

SELECT user_id,
	COUNT(*) AS total_txn,
    SUM(CASE WHEN HOUR(txn_time) BETWEEN 2 AND 4 THEN 1 ELSE 0 END) AS odd_txn
FROM transactions
GROUP BY user_id
HAVING 
	odd_txn / total_txn >= 0.8
    AND COUNT(*) >= 30
;

-- ============================== P6 ===================================
-- PATTERN 6 · MULE ACCOUNTS
-- =====================================================================

SELECT t1.user_id, count(*) as mule_count
FROM transactions t1
JOIN transactions t2
ON t1.user_id = t2.user_id
WHERE t1.txn_type = 'CREDIT'
	AND t2.txn_type = 'DEBIT'
	AND t2.txn_time > t1.txn_time
    AND timestampdiff(MINUTE, t1.txn_time, t2.txn_time) <= 30
    AND t2.amount >= 0.7 * t1.amount
GROUP BY user_id
HAVING count(*) >= 5;

-- ============================== P7 ===================================
-- PATTERN 7 · REFUND ABUSE
-- =====================================================================

SELECT user_id,
	COUNT(*) AS total_txn,
    SUM(txn_type = 'REFUND') AS refund_txn
FROM transactions
GROUP BY user_id
HAVING total_txn >= 20
	AND refund_txn >= 0.4 * total_txn
;

-- ============================== P8 ===================================
-- PATTERN 8 · MERCHANT COLLUSION
-- =====================================================================

WITH ranked_users as (
	SELECT merchant_id,
		user_id,
		SUM(amount) AS total_amt,
		ROW_NUMBER() OVER (PARTITION BY merchant_id ORDER BY SUM(amount) DESC) AS rn
	FROM transactions
	GROUP BY merchant_id, user_id
),
merchant_total as (
	SELECT merchant_id,
		SUM(total_amt) as merchant_total
	FROM ranked_users
	GROUP BY merchant_id
)
SELECT ru.merchant_id,
    SUM(ru.total_amt) AS top_5_total,
    mt.merchant_total
FROM ranked_users ru
join merchant_total mt
on ru.merchant_id = mt.merchant_id
WHERE ru.rn <=5
GROUP BY mt.merchant_id
HAVING SUM(ru.total_amt) >= 0.6 * mt.merchant_total;

-- ============================== P9 ===================================
-- PATTERN 9 · JUST-UNDER-THRESHOLD
-- =====================================================================

SELECT user_id, COUNT(*) AS total_txn
FROM transactions
WHERE amount = 9999.00
GROUP BY user_id
HAVING COUNT(*) >= 10;

-- ============================== P10 ===================================
-- PATTERN 10 · DORMANT-THEN-ACTIVE
-- =====================================================================

with prev_txn AS (
	SELECT user_id,
		txn_time,
		LAG(txn_time) OVER (PARTITION BY user_id ORDER BY txn_time) AS prev_txn
	FROM transactions
),
dormant_ids AS (
	SELECT
		user_id,
		txn_time,
		prev_txn
	FROM prev_txn
	WHERE DATEDIFF(txn_time, prev_txn) >= 90
)
SELECT di.user_id,
	COUNT(*) AS total_txn,
    SUM(t.amount)
FROM dormant_ids di
JOIN transactions t
ON di.user_id = t.user_id
WHERE t.txn_time >= di.txn_time
GROUP BY di.user_id
HAVING COUNT(*) >= 15;

-- ============================== P11 ===================================
-- PATTERN 11 · VELOCITY SPIKE
-- =====================================================================

WITH monthly AS (
    SELECT
        user_id,
        MONTH(txn_time) AS txn_month,
        COUNT(*) AS monthly_txn
    FROM transactions
    GROUP BY user_id, MONTH(txn_time)
)
SELECT
    user_id,
    AVG(monthly_txn) AS avg_txn,
    MAX(monthly_txn) AS peak_txn
FROM monthly
GROUP BY user_id
HAVING
    MAX(monthly_txn) >= 20
    AND MAX(monthly_txn) >= 5 * AVG(monthly_txn);
    
-- ============================== P12 ===================================
-- PATTERN 12 · GEOGRAPHIC IMPOSSIBILITY
-- =====================================================================

WITH user_txn AS (
    SELECT
        user_id,
        city,
        txn_time,
        LAG(city) OVER (
            PARTITION BY user_id
            ORDER BY txn_time
        ) AS prev_city,
        LAG(txn_time) OVER (
            PARTITION BY user_id
            ORDER BY txn_time
        ) AS prev_time
    FROM transactions
)
SELECT DISTINCT user_id
FROM user_txn
WHERE prev_city IS NOT NULL
  AND city <> prev_city
  AND TIMESTAMPDIFF(MINUTE, prev_time, txn_time) <= 60;