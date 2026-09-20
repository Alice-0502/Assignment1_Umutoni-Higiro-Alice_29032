-- ============================================================
-- Sunrise Supermarket — Sample Data
-- 6 customers | 9 products / 4 categories | 16 orders | 34 order items
-- ============================================================

INSERT INTO customers (customer_id, customer_name, email, city) VALUES
(1, 'Aline Uwase',          'aline.uwase@example.com',     'Kigali'),
(2, 'Eric Habimana',        'eric.habimana@example.com',   'Musanze'),
(3, 'Claudine Mukamana',    'claudine.mukamana@example.com','Kigali'),
(4, 'Jean Bosco Niyonzima', 'jean.niyonzima@example.com',  'Huye'),
(5, 'Grace Ingabire',       'grace.ingabire@example.com',  'Kigali'),
(6, 'Patrick Nshuti',       'patrick.nshuti@example.com',  'Rubavu'),
(7, 'Diane Umutoni',        'diane.umutoni@example.com',   'Kigali');

INSERT INTO products (product_id, product_name, category, price) VALUES
(1, 'Mineral Water 1.5L',    'Beverages', 1.20),
(2, 'Fanta Orange 500ml',    'Beverages', 0.80),
(3, 'White Bread Loaf',      'Bakery',    1.50),
(4, 'Croissant',             'Bakery',    0.90),
(5, 'Full Cream Milk 1L',    'Dairy',     1.60),
(6, 'Cheddar Cheese 200g',   'Dairy',     3.50),
(7, 'Bananas 1kg',           'Produce',   1.00),
(8, 'Tomatoes 1kg',          'Produce',   1.10),
(9, 'Rice 5kg',              'Grains',    6.00);

INSERT INTO orders (order_id, customer_id, order_date) VALUES
(1,  1, DATE '2026-01-05'),
(2,  1, DATE '2026-01-20'),
(3,  1, DATE '2026-02-10'),
(4,  2, DATE '2026-01-08'),
(5,  2, DATE '2026-02-01'),
(6,  3, DATE '2026-01-10'),
(7,  3, DATE '2026-01-25'),
(8,  3, DATE '2026-03-01'),
(9,  4, DATE '2026-01-15'),
(10, 5, DATE '2026-01-12'),
(11, 5, DATE '2026-01-30'),
(12, 5, DATE '2026-02-15'),
(13, 6, DATE '2026-01-18'),
(14, 6, DATE '2026-02-05'),
(15, 2, DATE '2026-03-10'),
(16, 4, DATE '2026-02-20');

INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES
(1,  1, 1, 2), (2,  1, 3, 1),
(3,  2, 2, 3), (4,  2, 4, 2),
(5,  3, 5, 1), (6,  3, 6, 1), (7,  3, 7, 2),
(8,  4, 1, 1), (9,  4, 9, 1),
(10, 5, 3, 2), (11, 5, 8, 3),
(12, 6, 2, 4), (13, 6, 5, 1),
(14, 7, 6, 1), (15, 7, 7, 1), (16, 7, 1, 2),
(17, 8, 9, 2), (18, 8, 4, 3),
(19, 9, 8, 2), (20, 9, 2, 1),
(21, 10, 1, 3), (22, 10, 3, 1),
(23, 11, 5, 2), (24, 11, 6, 1),
(25, 12, 7, 4), (26, 12, 9, 1),
(27, 13, 2, 2), (28, 13, 4, 1),
(29, 14, 8, 1), (30, 14, 1, 1),
(31, 15, 3, 2), (32, 15, 5, 1),
(33, 16, 6, 2), (34, 16, 9, 1);
