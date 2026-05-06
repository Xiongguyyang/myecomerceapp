-- Create products table in Supabase
-- Run this SQL in your Supabase SQL Editor

-- Create the products table
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    original_price DECIMAL(10, 2),
    image_url TEXT NOT NULL,
    category TEXT NOT NULL,
    rating DECIMAL(3, 2) DEFAULT 0.0,
    review_count INTEGER DEFAULT 0,
    in_stock BOOLEAN DEFAULT true,
    tags TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
CREATE INDEX IF NOT EXISTS idx_products_price ON products(price);
CREATE INDEX IF NOT EXISTS idx_products_in_stock ON products(in_stock);
CREATE INDEX IF NOT EXISTS idx_products_created_at ON products(created_at DESC);

-- Create a function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update updated_at
DROP TRIGGER IF EXISTS update_products_updated_at ON products;
CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Create policies for public read access
CREATE POLICY "Allow public read access" ON products
    FOR SELECT
    USING (true);

-- Create policies for authenticated users to insert/update/delete
CREATE POLICY "Allow authenticated insert" ON products
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "Allow authenticated update" ON products
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow authenticated delete" ON products
    FOR DELETE
    TO authenticated
    USING (true);

-- Insert sample product data
INSERT INTO products (name, description, price, original_price, image_url, category, rating, review_count, in_stock, tags) VALUES
('Wireless Headphones', 'Premium noise-cancelling wireless headphones with 30-hour battery life', 199.99, 299.99, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e', 'Electronics', 4.5, 1250, true, ARRAY['audio', 'wireless', 'premium']),

('Smart Watch Pro', 'Advanced fitness tracking smartwatch with heart rate monitor and GPS', 349.99, 449.99, 'https://images.unsplash.com/photo-1523275335684-37898b6baf30', 'Electronics', 4.7, 890, true, ARRAY['wearable', 'fitness', 'smart']),

('Leather Backpack', 'Genuine leather backpack with laptop compartment and USB charging port', 89.99, NULL, 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62', 'Fashion', 4.3, 456, true, ARRAY['leather', 'travel', 'laptop']),

('Running Shoes', 'Lightweight running shoes with advanced cushioning technology', 129.99, 159.99, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff', 'Sports', 4.6, 2340, true, ARRAY['running', 'sports', 'footwear']),

('Coffee Maker', 'Programmable coffee maker with thermal carafe and auto-brew feature', 79.99, 99.99, 'https://images.unsplash.com/photo-1517668808822-9ebb02f2a0e6', 'Home', 4.4, 678, true, ARRAY['kitchen', 'coffee', 'appliance']),

('Yoga Mat', 'Extra thick non-slip yoga mat with carrying strap', 34.99, NULL, 'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f', 'Sports', 4.2, 234, true, ARRAY['yoga', 'fitness', 'exercise']),

('Desk Lamp', 'LED desk lamp with adjustable brightness and USB charging port', 45.99, 59.99, 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c', 'Home', 4.5, 567, true, ARRAY['lighting', 'desk', 'led']),

('Bluetooth Speaker', 'Portable waterproof Bluetooth speaker with 12-hour battery', 69.99, 89.99, 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1', 'Electronics', 4.6, 1890, true, ARRAY['audio', 'portable', 'waterproof']),

('Sunglasses', 'Polarized UV protection sunglasses with designer frames', 149.99, 199.99, 'https://images.unsplash.com/photo-1572635196237-14b3f281503f', 'Fashion', 4.4, 345, true, ARRAY['eyewear', 'fashion', 'uv-protection']),

('Water Bottle', 'Insulated stainless steel water bottle keeps drinks cold for 24 hours', 29.99, NULL, 'https://images.unsplash.com/photo-1602143407151-7111542de6e8', 'Sports', 4.7, 1234, true, ARRAY['hydration', 'insulated', 'eco-friendly']),

('Wireless Mouse', 'Ergonomic wireless mouse with precision tracking', 39.99, 49.99, 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46', 'Electronics', 4.3, 890, true, ARRAY['computer', 'wireless', 'ergonomic']),

('Canvas Tote Bag', 'Eco-friendly canvas tote bag with multiple pockets', 24.99, NULL, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7', 'Fashion', 4.1, 123, true, ARRAY['bag', 'eco-friendly', 'canvas']),

('Protein Powder', 'Whey protein powder with 25g protein per serving', 49.99, 59.99, 'https://images.unsplash.com/photo-1579722821273-0f6c7d44362f', 'Sports', 4.5, 2456, true, ARRAY['nutrition', 'protein', 'fitness']),

('Air Purifier', 'HEPA air purifier for rooms up to 500 sq ft', 159.99, 199.99, 'https://images.unsplash.com/photo-1585771724684-38269d6639fd', 'Home', 4.6, 789, true, ARRAY['air-quality', 'hepa', 'home']),

('Phone Case', 'Shockproof protective phone case with card holder', 19.99, 29.99, 'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb', 'Electronics', 4.2, 3456, true, ARRAY['phone', 'protection', 'accessory']);

-- Verify the data was inserted
SELECT COUNT(*) as total_products FROM products;
SELECT category, COUNT(*) as count FROM products GROUP BY category ORDER BY count DESC;
