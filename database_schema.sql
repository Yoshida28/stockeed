-- Stocked Application Database Schema
-- Execute these SQL statements in your Supabase SQL editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. USERS TABLE
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  phone TEXT,
  company_name TEXT,
  role TEXT NOT NULL DEFAULT 'retail_client' CHECK (role IN ('distributor', 'retail_client')),
  address TEXT,
  gst_number TEXT,
  pan_number TEXT,
  cloud_id TEXT,
  sync_status TEXT DEFAULT 'synced',
  last_synced_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create trigger function to handle new user signups
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if user already exists in public.users
  IF NOT EXISTS (SELECT 1 FROM public.users WHERE email = NEW.email) THEN
    INSERT INTO public.users (
      email,
      cloud_id,
      role,
      created_at,
      updated_at
    ) VALUES (
      NEW.email,
      NEW.id,
      'retail_client', -- Default role for new users
      NOW(),
      NOW()
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger on auth.users table
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- 2. ITEMS TABLE
CREATE TABLE items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT,
  unit_price DECIMAL(10,2) DEFAULT 0.00,
  gst_percentage DECIMAL(5,2) DEFAULT 18.00,
  opening_stock INTEGER DEFAULT 0,
  current_stock INTEGER DEFAULT 0,
  low_stock_threshold INTEGER DEFAULT 10,
  description TEXT,
  barcode TEXT,
  sku TEXT,
  cloud_id TEXT,
  sync_status TEXT DEFAULT 'synced',
  last_synced_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. ORDERS TABLE
CREATE TABLE orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_number TEXT UNIQUE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'dispatched', 'delivered', 'cancelled')),
  client_id UUID REFERENCES users(id),
  client_name TEXT,
  total_amount DECIMAL(12,2) DEFAULT 0.00,
  gst_amount DECIMAL(12,2) DEFAULT 0.00,
  net_amount DECIMAL(12,2) DEFAULT 0.00,
  payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'partial', 'paid')),
  paid_amount DECIMAL(12,2) DEFAULT 0.00,
  notes TEXT,
  order_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  cloud_id TEXT,
  sync_status TEXT DEFAULT 'synced',
  last_synced_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. ORDER_ITEMS TABLE
CREATE TABLE order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  item_id UUID REFERENCES items(id),
  item_name TEXT,
  unit_price DECIMAL(10,2) DEFAULT 0.00,
  gst_percentage DECIMAL(5,2) DEFAULT 18.00,
  quantity INTEGER DEFAULT 1,
  total_amount DECIMAL(12,2) DEFAULT 0.00,
  gst_amount DECIMAL(12,2) DEFAULT 0.00,
  net_amount DECIMAL(12,2) DEFAULT 0.00,
  cloud_id TEXT,
  sync_status TEXT DEFAULT 'synced',
  last_synced_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. VOUCHERS TABLE
CREATE TABLE vouchers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  voucher_number TEXT UNIQUE,
  voucher_type TEXT NOT NULL CHECK (voucher_type IN ('sales', 'purchase', 'payment', 'receipt', 'journal')),
  voucher_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  party_name TEXT,
  party_id UUID REFERENCES users(id),
  description TEXT,
  total_amount DECIMAL(12,2) DEFAULT 0.00,
  gst_amount DECIMAL(12,2) DEFAULT 0.00,
  net_amount DECIMAL(12,2) DEFAULT 0.00,
  payment_mode TEXT CHECK (payment_mode IN ('cash', 'bank_transfer', 'upi', 'cheque')),
  reference_number TEXT,
  notes TEXT,
  cloud_id TEXT,
  sync_status TEXT DEFAULT 'synced',
  last_synced_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. VOUCHER_ITEMS TABLE
CREATE TABLE voucher_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  voucher_id UUID REFERENCES vouchers(id) ON DELETE CASCADE,
  item_id UUID REFERENCES items(id),
  item_name TEXT,
  quantity INTEGER DEFAULT 1,
  unit_price DECIMAL(10,2) DEFAULT 0.00,
  gst_percentage DECIMAL(5,2) DEFAULT 18.00,
  total_amount DECIMAL(12,2) DEFAULT 0.00,
  gst_amount DECIMAL(12,2) DEFAULT 0.00,
  net_amount DECIMAL(12,2) DEFAULT 0.00,
  cloud_id TEXT,
  sync_status TEXT DEFAULT 'synced',
  last_synced_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. PAYMENTS TABLE
CREATE TABLE payments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  payment_number TEXT UNIQUE,
  payment_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  party_id UUID REFERENCES users(id),
  party_name TEXT,
  payment_type TEXT NOT NULL CHECK (payment_type IN ('received', 'paid')),
  amount DECIMAL(12,2) NOT NULL,
  payment_mode TEXT NOT NULL CHECK (payment_mode IN ('cash', 'bank_transfer', 'upi', 'cheque')),
  reference_number TEXT,
  bank_name TEXT,
  account_number TEXT,
  description TEXT,
  related_order_id UUID REFERENCES orders(id),
  related_voucher_id UUID REFERENCES vouchers(id),
  cloud_id TEXT,
  sync_status TEXT DEFAULT 'synced',
  last_synced_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. EXPENSES TABLE
CREATE TABLE expenses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  expense_number TEXT UNIQUE,
  expense_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  category TEXT NOT NULL,
  description TEXT NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  payment_mode TEXT CHECK (payment_mode IN ('cash', 'bank_transfer', 'upi', 'cheque')),
  reference_number TEXT,
  vendor_name TEXT,
  gst_number TEXT,
  gst_amount DECIMAL(12,2) DEFAULT 0.00,
  net_amount DECIMAL(12,2) DEFAULT 0.00,
  notes TEXT,
  cloud_id TEXT,
  sync_status TEXT DEFAULT 'synced',
  last_synced_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. STOCK_MOVEMENTS TABLE (for audit trail)
CREATE TABLE stock_movements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  item_id UUID REFERENCES items(id),
  movement_type TEXT NOT NULL CHECK (movement_type IN ('in', 'out', 'adjustment')),
  quantity INTEGER NOT NULL,
  previous_stock INTEGER NOT NULL,
  new_stock INTEGER NOT NULL,
  reference_type TEXT CHECK (reference_type IN ('order', 'voucher', 'manual')),
  reference_id UUID,
  notes TEXT,
  cloud_id TEXT,
  sync_status TEXT DEFAULT 'synced',
  last_synced_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. SETTINGS TABLE (for app configuration)
CREATE TABLE settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  setting_key TEXT NOT NULL,
  setting_value TEXT,
  setting_type TEXT DEFAULT 'string',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, setting_key)
);

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_items_category ON items(category);
CREATE INDEX idx_items_name ON items(name);
CREATE INDEX idx_orders_client_id ON orders(client_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_vouchers_voucher_type ON vouchers(voucher_type);
CREATE INDEX idx_vouchers_voucher_date ON vouchers(voucher_date);
CREATE INDEX idx_payments_party_id ON payments(party_id);
CREATE INDEX idx_payments_payment_date ON payments(payment_date);
CREATE INDEX idx_expenses_category ON expenses(category);
CREATE INDEX idx_expenses_expense_date ON expenses(expense_date);
CREATE INDEX idx_stock_movements_item_id ON stock_movements(item_id);
CREATE INDEX idx_stock_movements_created_at ON stock_movements(created_at);

-- Create RLS (Row Level Security) policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE vouchers ENABLE ROW LEVEL SECURITY;
ALTER TABLE voucher_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- Basic RLS policies (you can customize these based on your needs)
CREATE POLICY "Users can view their own data" ON users FOR SELECT USING (auth.uid()::text = cloud_id);
CREATE POLICY "Users can insert their own data" ON users FOR INSERT WITH CHECK (auth.uid()::text = cloud_id);
CREATE POLICY "Users can update their own data" ON users FOR UPDATE USING (auth.uid()::text = cloud_id);

-- Similar policies for other tables (simplified for now)
CREATE POLICY "Enable read access for authenticated users" ON items FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Enable insert access for authenticated users" ON items FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Enable update access for authenticated users" ON items FOR UPDATE USING (auth.role() = 'authenticated');

-- Create functions for automatic timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for automatic updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_items_updated_at BEFORE UPDATE ON items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_order_items_updated_at BEFORE UPDATE ON order_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_vouchers_updated_at BEFORE UPDATE ON vouchers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_voucher_items_updated_at BEFORE UPDATE ON voucher_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON expenses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_settings_updated_at BEFORE UPDATE ON settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert some default categories for items
INSERT INTO settings (setting_key, setting_value, setting_type) VALUES
('item_categories', '["Electronics", "Clothing", "Food & Beverages", "Home & Garden", "Sports", "Books", "Automotive", "Health & Beauty", "Toys & Games", "Other"]', 'json'),
('default_gst_rate', '18.0', 'number'),
('default_low_stock_threshold', '10', 'number'),
('company_name', 'Stocked Business', 'string'),
('app_version', '1.0.0', 'string');

-- Create a view for dashboard statistics
CREATE VIEW dashboard_stats AS
SELECT 
  (SELECT COUNT(*) FROM items) as total_items,
  (SELECT COUNT(*) FROM items WHERE current_stock <= low_stock_threshold) as low_stock_items,
  (SELECT COUNT(*) FROM orders WHERE status = 'pending') as pending_orders,
  (SELECT COUNT(*) FROM orders WHERE DATE(created_at) = CURRENT_DATE) as today_orders,
  (SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE DATE(created_at) = CURRENT_DATE) as today_sales,
  (SELECT COALESCE(SUM(amount), 0) FROM payments WHERE payment_type = 'received' AND DATE(payment_date) = CURRENT_DATE) as today_payments,
  (SELECT COALESCE(SUM(amount), 0) FROM expenses WHERE DATE(expense_date) = CURRENT_DATE) as today_expenses;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated; 