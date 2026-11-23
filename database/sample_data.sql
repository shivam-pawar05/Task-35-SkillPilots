INSERT INTO categories(category_name)
VALUES
('Electronics'),
('Clothing'),
('Books'),
('Accessories');

INSERT INTO suppliers(supplier_name, email, phone)
VALUES
('ABC Suppliers', 'abc@example.com', '9876543210'),
('XYZ Traders', 'xyz@example.com', '9876543211');

INSERT INTO warehouses(warehouse_name, location)
VALUES
('Main Warehouse', 'Nagpur'),
('Second Warehouse', 'Mumbai');

INSERT INTO customers(customer_name, email, phone)
VALUES
('Rahul Sharma', 'rahul@example.com', '9876500001'),
('Amit Patil', 'amit@example.com', '9876500002');

INSERT INTO products(
    product_name, category_id, supplier_id, price
)
VALUES
('Laptop', 1, 1, 55000),
('Mobile Phone', 1, 1, 18000),
('T-Shirt', 2, 2, 500),
('Python Programming Book', 3, 2, 650),
('Headphones', 4, 1, 1200);

INSERT INTO inventory(
    product_id, warehouse_id, quantity, reorder_level
)
VALUES
(1, 1, 50, 10),
(2, 1, 100, 20),
(3, 1, 200, 30),
(4, 1, 75, 15),
(5, 1, 40, 10);