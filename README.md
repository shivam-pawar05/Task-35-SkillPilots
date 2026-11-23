
# E-Commerce Inventory Management System

## Project Description
This project manages products, suppliers, customers, warehouses, stock levels and customer orders.

It uses PostgreSQL for database management, Python Flask for REST API development and Power BI for business intelligence.

## Technologies Used
- Python
- Flask
- PostgreSQL
- SQL and PL/pgSQL
- Microsoft Power BI
- GitHub Actions

## Main Modules
1. Product Management
2. Category Management
3. Supplier Management
4. Warehouse Management
5. Inventory Management
6. Order Processing
7. Stock Management
8. Audit Logging
9. Sales Dashboard

## Installation

### Step 1: Create Database
Create a PostgreSQL database named:

ecommerce_db

### Step 2: Execute SQL Files

Run these files in order:

1. database/schema.sql
2. database/functions.sql
3. database/triggers.sql
4. database/sample_data.sql

### Step 3: Install Python Packages

Open terminal inside the backend folder:

pip install -r requirements.txt

### Step 4: Configure Database

Edit the .env file and enter your PostgreSQL password.

### Step 5: Run Flask Application

python app.py

### Step 6: Open API

http://127.0.0.1:5000/

## API Endpoints

GET /products
POST /products
PUT /products/1
DELETE /products/1
GET /inventory
POST /orders

## Dashboard
Connect Power BI to PostgreSQL and create inventory, stock and sales reports.

## CI/CD
GitHub Actions automatically checks Python syntax and executes database scripts.

## Author
E-Commerce Inventory Management System
