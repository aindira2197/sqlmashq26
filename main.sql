WITH CustomerHistory AS (
    SELECT 
        c.cust_id,
        c.cust_name,
        MIN(o.order_date) AS first_purchase,
        MAX(o.order_date) AS last_purchase,
        COUNT(o.order_id) AS total_orders,
        SUM(o.total_amount) AS total_spent,
        DATEDIFF(MAX(o.order_date), MIN(o.order_date)) AS customer_tenure_days
    FROM Customers c
    JOIN Orders o ON c.cust_id = o.cust_id
    GROUP BY c.cust_id, c.cust_name
),
CLV_Calculation AS (
    SELECT 
        cust_id,
        cust_name,
        total_spent / total_orders AS average_order_value,
        total_orders / NULLIF((customer_tenure_days / 30), 0) AS purchase_frequency_monthly,
        (total_spent / total_orders) * (total_orders / NULLIF((customer_tenure_days / 30), 0)) * 12 AS estimated_annual_value
    FROM CustomerHistory
)
SELECT 
    cust_name,
    FORMAT(average_order_value, 2) AS aov,
    ROUND(purchase_frequency_monthly, 2) AS monthly_freq,
    FORMAT(estimated_annual_value, 2) AS projected_clv_1yr,
    CASE 
        WHEN estimated_annual_value > 10000 THEN 'VIP_HIGH_VALUE'
        WHEN estimated_annual_value BETWEEN 5000 AND 10000 THEN 'PREMIUM'
        WHEN estimated_annual_value BETWEEN 1000 AND 5000 THEN 'STANDARD'
        ELSE 'LOW_ENGAGEMENT'
    END AS customer_tier
FROM CLV_Calculation
ORDER BY estimated_annual_value DESC;
