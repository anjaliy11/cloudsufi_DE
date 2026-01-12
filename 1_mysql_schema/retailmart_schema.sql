
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100),
    description VARCHAR(255)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(150),
    category_id INT,
    price DECIMAL(10,2),
    cost DECIMAL(10,2),
    stock_quantity INT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(150),
    email VARCHAR(150),
    gender VARCHAR(10),
    city VARCHAR(100),
    join_date DATE
);


DROP TABLE IF EXISTS voucher_redemptions;
DROP TABLE IF EXISTS vouchers;
DROP TABLE IF EXISTS sales_items;
DROP TABLE IF EXISTS sales_transactions;
DROP TABLE IF EXISTS returns;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    category_id INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL CHECK (unit_price >= 0),
    cost_price DECIMAL(12,2) NOT NULL CHECK (cost_price >= 0),
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0),
    is_active TINYINT(1) NOT NULL DEFAULT 1 CHECK (is_active IN (0,1)),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE INDEX idx_products_category ON products(category_id);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    city VARCHAR(100) NOT NULL,
    registration_date DATE NOT NULL,
    loyalty_tier VARCHAR(50) NOT NULL,
    UNIQUE KEY uq_customers_email (email)
);

CREATE TABLE sales_transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NULL,
    store_id INT NOT NULL,
    transaction_date DATE NOT NULL,
    transaction_time TIME NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    total_amount DECIMAL(14,2) NOT NULL CHECK (total_amount >= 0),
    discount_amount DECIMAL(14,2) NOT NULL CHECK (discount_amount >= 0),
    tax_amount DECIMAL(14,2) NOT NULL CHECK (tax_amount >= 0),
    net_amount DECIMAL(14,2) NOT NULL CHECK (net_amount >= 0),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE INDEX idx_salestransactions_customer ON sales_transactions(customer_id);
CREATE INDEX idx_salestransactions_store ON sales_transactions(store_id);

CREATE TABLE sales_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(12,2) NOT NULL CHECK (unit_price >= 0),
    line_total DECIMAL(14,2) NOT NULL CHECK (line_total >= 0),
    FOREIGN KEY (transaction_id) REFERENCES sales_transactions(transaction_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
);

CREATE INDEX idx_salesitems_transaction ON sales_items(transaction_id);
CREATE INDEX idx_salesitems_product ON sales_items(product_id);

CREATE TABLE vouchers (
    voucher_id INT PRIMARY KEY AUTO_INCREMENT,
    voucher_code VARCHAR(50) NOT NULL,
    voucher_type VARCHAR(20) NOT NULL,
    discount_value DECIMAL(12,2) NOT NULL CHECK (discount_value >= 0),
    min_purchase_amount DECIMAL(14,2) NOT NULL CHECK (min_purchase_amount >= 0),
    max_discount_amount DECIMAL(14,2) NULL,
    valid_from DATE NOT NULL,
    valid_to DATE NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1 CHECK (is_active IN (0,1)),
    UNIQUE KEY uq_vouchers_code (voucher_code)
);

CREATE TABLE voucher_redemptions (
    redemption_id INT PRIMARY KEY AUTO_INCREMENT,
    voucher_id INT NOT NULL,
    transaction_id INT NOT NULL,
    customer_id INT NULL,
    redemption_date DATE NOT NULL,
    discount_applied DECIMAL(12,2) NOT NULL CHECK (discount_applied >= 0),
    FOREIGN KEY (voucher_id) REFERENCES vouchers(voucher_id) ON DELETE CASCADE,
    FOREIGN KEY (transaction_id) REFERENCES sales_transactions(transaction_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL
);

CREATE INDEX idx_voucher_redemptions_voucher ON voucher_redemptions(voucher_id);
CREATE INDEX idx_voucher_redemptions_transaction ON voucher_redemptions(transaction_id);

CREATE TABLE returns (
    return_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT NOT NULL,
    item_id INT NULL,
    customer_id INT NULL,
    product_id INT NOT NULL,
    return_date DATE NOT NULL,
    return_quantity INT NOT NULL CHECK (return_quantity > 0),
    return_reason VARCHAR(255) NOT NULL,
    refund_amount DECIMAL(14,2) NOT NULL CHECK (refund_amount >= 0),
    refund_status VARCHAR(50) NOT NULL,
    FOREIGN KEY (transaction_id) REFERENCES sales_transactions(transaction_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES sales_items(item_id) ON DELETE SET NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
);

CREATE INDEX idx_returns_transaction ON returns(transaction_id);
CREATE INDEX idx_returns_product ON returns(product_id);
