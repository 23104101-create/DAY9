# Hexaware Day 9 – Set 3: Telecom Low-Balance Follow-up

## What the assignment asks
1. Create `vw_prepaid_subscribers` and `vw_recharge_summary`; hide postpaid users and sensitive columns.
2. Create `sp_recharge` with amount/plan validation, a transaction, balance update, recharge-history insert, and an OUT parameter for the new balance.
3. Create `fn_validity_days_left` and use it in a SELECT.
4. Use a cursor with a NOT FOUND handler to notify every prepaid subscriber below 50 units. Repeat with `INSERT ... SELECT` and compare execution time.
5. Demonstrate `DECLARE ... HANDLER FOR SQLEXCEPTION` and `SIGNAL`.

## Files
- `schema_and_sample_data.sql`: creates the database and tables and inserts demo rows.
- `views.sql`: creates the two views.
- `procedures.sql`: creates the recharge procedure and validity function, with demo calls.
- `cursor.sql`: creates cursor and set-based notification procedures and measures elapsed time.

## Assumptions
The assignment does not specify table columns, so this solution uses a simple schema:
- `subscribers`: subscriber details, PREPAID/POSTPAID type, balance, plan and validity date.
- `plans`: recharge plan and validity days.
- `recharge_history`: records each successful recharge.
- `notifications`: stores low-balance messages.

Phone number and email are treated as sensitive and are excluded from the views. Only PREPAID subscribers appear in the prepaid view.

## Run order in MySQL Workbench
1. Run `schema_and_sample_data.sql`.
2. Run `views.sql`.
3. Run `procedures.sql`.
4. Run `cursor.sql`.

Run each file in the same MySQL connection/session where practical. `procedures.sql` performs a demo recharge for subscriber 101, so running it again adds another recharge and increases that subscriber's balance again.

## Concepts in simple English
- **VIEW:** A saved SELECT query. It behaves like a virtual table. It can hide columns and filter rows.
- **Stored procedure:** A saved group of SQL statements that you execute with `CALL`.
- **IN parameter:** Sends a value into a procedure.
- **OUT parameter:** Sends a result back to the caller.
- **Function:** A stored program that returns one value and can be used in a SELECT.
- **Transaction:** A group of database changes treated as one unit. `COMMIT` saves; `ROLLBACK` cancels.
- **Handler:** Defines what MySQL should do when a condition or error occurs.
- **SIGNAL SQLSTATE '45000':** Raises a user-defined business error.
- **Cursor:** Fetches query results one row at a time.
- **NOT FOUND handler:** Sets a flag when the cursor has no more rows.
- **Set-based SQL:** Processes all matching rows in one statement, often more efficient than a cursor for bulk work.

## Cursor vs set-based comparison
| Cursor | INSERT ... SELECT |
|---|---|
| Processes one row at a time | Processes matching rows as a set |
| Needs OPEN, FETCH, LOOP and CLOSE | Usually one INSERT statement |
| Useful when each row needs different procedural logic | Best for the same operation on many rows |
| Usually slower for bulk inserts | Usually faster for bulk inserts |

The timing values are measured on your MySQL server when you run the script. Do not copy invented timing numbers into your submission. Run both tests on the same data and compare the two returned microsecond values. Small sample tables may show noisy results.

## Expected low-balance sample rows
Before running the recharge demo, prepaid subscribers below 50 units are:
- Arun (25)
- Ravi (10)
- Kiran (45)

The recharge demo adds 99 units to Arun, so if you run `cursor.sql` after `procedures.sql`, Arun will no longer be below 50. That is expected. To restore the original sample values, run the UPDATE below before running the cursor comparison:
```sql
UPDATE subscribers
SET balance = CASE subscriber_id
    WHEN 101 THEN 25.00
    WHEN 102 THEN 75.00
    WHEN 103 THEN 10.00
    WHEN 104 THEN 0.00
    WHEN 105 THEN 45.00
    WHEN 106 THEN 150.00
END;
```

## Short presentation to trainer
Good morning, sir. My Day 9 assignment is Telecom Low-Balance Follow-up. I created tables for subscribers, recharge plans, recharge history and notifications. First, I created views to show prepaid subscribers and recharge summaries while hiding sensitive contact details. Next, I created a stored procedure named `sp_recharge`. It validates the recharge amount and plan, updates the subscriber balance and inserts a recharge-history record inside a transaction. It returns the new balance using an OUT parameter. I also created the function `fn_validity_days_left` to calculate remaining validity days. Then I used a cursor and a NOT FOUND handler to insert notifications for prepaid subscribers whose balance is below 50 units. I repeated the same task using INSERT SELECT and measured both execution times. Finally, I demonstrated error handling using an SQLEXCEPTION handler and SIGNAL SQLSTATE 45000. Thank you.

## Important demonstration note
The sample schema and data are created for this solution because the assignment handout gives the tasks but does not provide a database schema. Explain this assumption if your trainer asks.
