-- ============================================================
-- Sunrise Supermarket — Schema
-- DBMS: PostgreSQL 16
-- ============================================================

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
  customer_id   NUMERIC PRIMARY KEY,
  customer_name VARCHAR(100),
  email         VARCHAR(100),
  city          VARCHAR(50)
);

CREATE TABLE products (
  product_id    NUMERIC PRIMARY KEY,
  product_name  VARCHAR(100),
  category      VARCHAR(50),
  price         NUMERIC(10,2)
);

CREATE TABLE orders (
  order_id      NUMERIC PRIMARY KEY,
  customer_id   NUMERIC REFERENCES customers(customer_id),
  order_date    DATE
);

CREATE TABLE order_items (
  order_item_id NUMERIC PRIMARY KEY,
  order_id      NUMERIC REFERENCES orders(order_id),
  product_id    NUMERIC REFERENCES products(product_id),
  quantity      NUMERIC
);
