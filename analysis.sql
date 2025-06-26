use ecommerce

    # Menghitung tanggal pembelian terakhir (Recency), jumlah pembelian unik (Frequency), 
    # dan total nilai transaksi (Monetary) untuk setiap pelanggan, 
    # sambil mendeteksi anomali dengan mengecualikan transaksi decoy_flag = 0
WITH CustomerRFM AS (
    SELECT
        customer_id,
        MAX(order_date) AS last_order_date,
        COUNT(DISTINCT order_id) AS frequency_count,
        SUM(payment_value) AS monetary_value
    FROM
        e_commerce_transactions
    WHERE
        decoy_flag = 0 
    GROUP BY
        customer_id
),

    # Memberikan skor (1-5) untuk Recency, Frequency, dan Monetary 
    # kepada setiap pelanggan berdasarkan kuintil
RFMScores AS (
    SELECT
        customer_id,
        DATEDIFF('2025-06-26', last_order_date) AS recency_days,
        frequency_count,
        monetary_value,
        NTILE(5) OVER (ORDER BY DATEDIFF('2025-06-26', last_order_date) DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency_count ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary_value ASC) AS m_score
    FROM
        CustomerRFM
)

    # Menggunakan kombinasi skor RFM untuk menetapkan segmen pelanggan, 
    # seperti Champions, Loyal Customers, New Customers, At Risk, Lost Customers, 
    # dan Potential Loyalist
SELECT
    customer_id,
    recency_days,
    frequency_count,
    monetary_value,
    r_score,
    f_score,
    m_score,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions' -- R4-5, F4-5, M4-5
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers' -- R3-5, F3-5, M3-5 (tidak termasuk Champions)
        WHEN r_score >= 4 AND f_score <= 2 AND m_score <= 2 THEN 'New Customers' -- R4-5, F1-2, M1-2
        WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'At Risk' -- R1-2, F3-5, M3-5
        WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Lost Customers' -- R1-2, F1-2, M1-2
        ELSE 'Potential Loyalist' 
    END AS customer_segment
FROM
    RFMScores
ORDER BY
    customer_id;
