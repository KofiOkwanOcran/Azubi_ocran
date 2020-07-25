-- Question 1
SELECT COUNT(*) FROM users;

-- Question 2
SELECT COUNT(*) FROM transfers
WHERE send_amount_currency = 'CFA';

-- Question 3
SELECT COUNT(DISTINCT u_id)
FROM transfers
WHERE send_amount_currency = 'CFA';

-- Question 4
SELECT DATE_PART('month', when_created) AS month_of_atx, COUNT(atx_id)
FROM agent_transactions 
WHERE DATE_PART('year',when_created) = 2018 
GROUP BY month_of_atx;

-- Question 5
WITH main_tb AS (
    SELECT * FROM agent_transactions 
    WHERE when_created BETWEEN 
        ((SELECT MAX(when_created) FROM agent_transactions) - interval '6 day')
            AND 
        ((SELECT MAX(when_created) FROM agent_transactions) + interval '1 day')
    )
SELECT
    COUNT(DISTINCT tb1.agent_id) AS net_depositors, COUNT(DISTINCT tb2.agent_id) AS net_withdrawers 
FROM 
    (SELECT agent_id FROM main_tb 
     GROUP BY agent_id 
     HAVING SUM(amount) < 0) AS tb1, 
    (SELECT agent_id FROM main_tb
     GROUP BY agent_id
     HAVING SUM(amount) > 0) AS tb2;
 
-- Question 6
WITH main_tb AS (
    SELECT * FROM agent_transactions 
    WHERE when_created BETWEEN 
        ((SELECT MAX(when_created) FROM agent_transactions) - interval '6 day')
            AND 
        ((SELECT MAX(when_created) FROM agent_transactions) + interval '1 day')
    )     
SELECT agents.city, COUNT(atx.atx_id) atx_volume
FROM main_tb AS atx
JOIN agents
ON atx.agent_id = agents.agent_id
GROUP BY  agents.city;

-- Question 7
WITH main_tb AS (
    SELECT * FROM agent_transactions 
    WHERE when_created BETWEEN 
        ((SELECT MAX(when_created) FROM agent_transactions) - interval '6 day')
            AND 
        ((SELECT MAX(when_created) FROM agent_transactions) + interval '1 day')
    ) 
SELECT agents.country, agents.city, SUM(atx.amount) atx_volume
FROM main_tb AS atx
JOIN agents
ON atx.agent_id = agents.agent_id
GROUP BY agents.city, agents.country;

-- Question 8
SELECT wallets.ledger_location AS country, transfers.kind, SUM(transfers.send_amount_scalar) AS send_volume
FROM transfers
JOIN wallets
ON transfers.source_wallet_id = wallets.wallet_id
GROUP BY wallets.ledger_location, transfers.kind;

-- Question 9
SELECT wallets.ledger_location AS country, transfers.kind, SUM(transfers.send_amount_scalar) AS send_volume,
       COUNT(transfers.send_amount_scalar) AS transaction_count, COUNT(DISTINCT transfers.u_id) AS unique_senders_number
FROM transfers
JOIN wallets
ON transfers.source_wallet_id = wallets.wallet_id
GROUP BY wallets.ledger_location, transfers.kind;

-- Question 10
SELECT wallets.wallet_id, SUM(transfers.send_amount_scalar) total_transfers
FROM wallets
JOIN transfers
ON wallets.wallet_id = transfers.source_wallet_id
WHERE transfers.send_amount_scalar > 10000000 AND transfers.send_amount_currency = 'CFA'
GROUP BY  wallets.wallet_id;