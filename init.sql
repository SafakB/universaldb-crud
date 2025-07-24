-- Database initialization script
-- This script will be executed when the MySQL container starts for the first time

USE universaldb;

-- Create a sample categories table
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO categories (name, description) VALUES 
('Technology', 'Technology related news and articles'),
('Sports', 'Sports news and updates'),
('Health', 'Health and wellness articles'),
('Business', 'Business and finance news'),
('Entertainment', 'Entertainment and celebrity news');

-- Create a sample articles table
CREATE TABLE IF NOT EXISTS articles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    content TEXT,
    category_id INT,
    author VARCHAR(255),
    published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Insert sample articles
INSERT INTO articles (title, content, category_id, author, published) VALUES 
('Latest Tech Trends', 'Content about latest technology trends...', 1, 'John Doe', TRUE),
('Football Championship', 'Sports news about football championship...', 2, 'Jane Smith', TRUE),
('Healthy Living Tips', 'Tips for maintaining a healthy lifestyle...', 3, 'Dr. Wilson', TRUE),
('Market Analysis', 'Current market trends and analysis...', 4, 'Mike Johnson', FALSE),
('Movie Reviews', 'Latest movie reviews and ratings...', 5, 'Sarah Brown', TRUE);

-- Create users table for authentication
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'editor', 'user') DEFAULT 'user',
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert sample users (password is 'password123' hashed)
INSERT INTO users (username, email, password_hash, role) VALUES 
('admin', 'admin@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin'),
('editor', 'editor@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'editor'),
('user1', 'user1@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user');

COMMIT;