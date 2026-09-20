# PL/SQL Assignment One: Sunrise Supermarket Database

| | |
|---|---|
| **Course** | Database Systems / PL/SQL |
| **Student** | Umutoni Higiro Alice |
| **Student ID** | 29032 |
| **Academic Group** | Group B |
| **Submission Date** | September 2026 |
| **Database** | Oracle Database 21c Express Edition (Release 21.3.0.0.0) |
| **Client Tool** | Oracle SQL*Plus |

---

## 1. Project Summary

Sunrise Supermarket is a regional grocery chain with branches in **Kigali, Musanze, Huye, and Rubavu**. Its shelves are organised into three departments: **Produce, Dairy, and Bakery**.

For this assignment I designed a compact relational database for the store and wrote SQL queries that answer the kind of questions management would ask:

- Which cities do our customers come from, and which registered accounts have never placed an order?
- What does a typical basket look like across product categories?
- Which customers spend more than the average customer?
- How frequently do customers return to shop again?
- How does total revenue build up over time?

## 2. Requirements

- Oracle Database 21c Express Edition
- Pluggable database `XEPDB1`, listening on the default port `1521`
- SQL*Plus command-line client

## 3. How to Run

**Step 1: Connect to the pluggable database**

```bash
sqlplus myuser/password@localhost:1521/XEPDB1
```

**Step 2: Set up the display format** (avoids truncated columns and wrapped lines)

```sql
SET LINESIZE 200;
SET PAGESIZE 50;
COLUMN customer_name FORMAT A20;
COLUMN product_name FORMAT A22;
COLUMN city FORMAT A15;
COLUMN category FORMAT A12;
```

**Step 3: Create the schema and load the data**

Run the `CREATE TABLE` statements in Section 4, then the `INSERT` statements for the sample data, and end with `COMMIT;`.

> **Running the script again?** Drop the tables from child to parent first, or use `CASCADE CONSTRAINTS PURGE`:
> `order_items` → `orders` → `products` → `customers`

## 4. Database Design

Relationships between the tables:

```
customers (1) ────< orders (1) ────< order_items >──── (1) products
```

```sql
CREATE TABLE customers (
  customer_id   NUMBER PRIMARY KEY,
  customer_name VARCHAR2(100),
  email         VARCHAR2(100),
  city          VARCHAR2(50)
);

CREATE TABLE products (
  product_id   NUMBER PRIMARY KEY,
  product_name VARCHAR2(100),
  category     VARCHAR2(50),
  price        NUMBER(10,2)
);

CREATE TABLE orders (
  order_id    NUMBER PRIMARY KEY,
  customer_id NUMBER REFERENCES customers(customer_id),
  order_date  DATE
);

CREATE TABLE order_items (
  order_item_id NUMBER PRIMARY KEY,
  order_id      NUMBER REFERENCES orders(order_id),
  product_id    NUMBER REFERENCES products(product_id),
  quantity      NUMBER
);
```

### Sample data at a glance

| Table | Rows | Notes |
|---|---|---|
| `customers` | 6 | One customer, Fiona Gallagher, has never ordered (inactive) |
| `products` | 8 | 2 Produce, 3 Dairy, 3 Bakery |
| `orders` | 15 | Placed between August and September 2026 |
| `order_items` | 27 | Line items spread across all orders |

## 5. Queries and Their Purpose

### Section A: Multi-Table JOINs

| # | Query | Technique | What it shows |
|---|---|---|---|
| 1 | Customer Order Activity | `INNER JOIN` | Every order with the customer's name, city, and order date (15 rows). Useful for linking order volume to delivery hubs. |
| 2 | Line-Item Details | `JOIN` | Every line item with product, category, price, and quantity (27 rows). Reveals fast-moving items such as Bananas and Organic Apples compared with niche items like Cheddar Cheese. |
| 3 | Inactive Customer Audit | `LEFT JOIN` | All customers alongside their orders (16 rows). Fiona Gallagher (ID 6) appears with `NULL` order columns, so marketing can target her with a welcome offer. |

```sql
-- Query 1
SELECT o.order_id, c.customer_name, c.city, o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_id;

-- Query 2
SELECT oi.order_item_id, oi.order_id, p.product_name, p.category, p.price, oi.quantity
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.order_item_id;

-- Query 3
SELECT c.customer_id, c.customer_name, c.city, o.order_id, o.order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.order_id;
```

### Section B: Common Table Expression (CTE)

**Query 4: High-Value Customers (above-average spend)**

The CTE calculates each customer's total spend. A scalar subquery then computes the average of those totals, and only customers above that average are returned. Management can use this list to build loyalty tiers or early-access offers.

```sql
WITH customer_spending AS (
    SELECT c.customer_id, c.customer_name,
           SUM(oi.quantity * p.price) AS total_spent
    FROM customers c
    JOIN orders o       ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p     ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, total_spent
FROM customer_spending
WHERE total_spent > (SELECT AVG(total_spent) FROM customer_spending)
ORDER BY total_spent DESC;
```

### Section C: Window Functions

| # | Query | Function | What it shows |
|---|---|---|---|
| 5 | Customer Spending Rank | `DENSE_RANK()` | Ranks customers by total spend; tied customers share a rank and no rank numbers are skipped. |
| 6 | Order Sequence per Customer | `ROW_NUMBER()` | Numbers each customer's orders by date. 1 is the first purchase; higher numbers are repeat visits. |
| 7 | Cumulative Revenue | `SUM() OVER (... ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)` | Running total of gross revenue over time. |
| 8 | Time Between Orders | `LAG()` + `COUNT() OVER` | Days between consecutive orders for repeat customers; customers with a single order are excluded. |

```sql
-- Query 5
WITH customer_totals AS (
    SELECT c.customer_id, c.customer_name,
           SUM(oi.quantity * p.price) AS total_spent
    FROM customers c
    JOIN orders o       ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p     ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, total_spent,
       DENSE_RANK() OVER (ORDER BY total_spent DESC) AS spending_rank
FROM customer_totals;

-- Query 6
SELECT customer_id, order_id, order_date,
       ROW_NUMBER() OVER (
           PARTITION BY customer_id
           ORDER BY order_date, order_id
       ) AS order_sequence_number
FROM orders;

-- Query 7
WITH daily_revenue AS (
    SELECT o.order_date,
           SUM(oi.quantity * p.price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p     ON oi.product_id = p.product_id
    GROUP BY o.order_date
)
SELECT order_date, revenue,
       SUM(revenue) OVER (
           ORDER BY order_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS cumulative_revenue
FROM daily_revenue
ORDER BY order_date;

-- Query 8
WITH order_gaps AS (
    SELECT customer_id, order_id, order_date,
           LAG(order_date) OVER (
               PARTITION BY customer_id
               ORDER BY order_date, order_id
           ) AS previous_order_date,
           COUNT(*) OVER (PARTITION BY customer_id) AS total_orders
    FROM orders
)
SELECT customer_id, order_id, order_date, previous_order_date,
       order_date - previous_order_date AS days_since_last_order
FROM order_gaps
WHERE total_orders > 1
ORDER BY customer_id, order_date, order_id;
```
