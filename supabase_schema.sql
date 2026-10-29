-- ===================================================================
-- IZDIIHAR CELL - SUPABASE DATABASE SCHEMA (POSTGRESQL CLOUD)
-- Jalankan skrip ini di menu SQL Editor di Supabase Dashboard Anda.
-- ===================================================================

-- 1. TABEL UTAMA SINKRONISASI REAL-TIME (LENGKAP SEMUA DATA TOKO)
CREATE TABLE IF NOT EXISTS konter_store (
  id TEXT PRIMARY KEY DEFAULT 'main',
  data JSONB NOT NULL,
  version BIGINT DEFAULT 1,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. TABEL PRODUK & STOK
CREATE TABLE IF NOT EXISTS products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'Umum',
  stock NUMERIC NOT NULL DEFAULT 0,
  cost NUMERIC NOT NULL DEFAULT 0,
  price NUMERIC NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. TABEL TRANSAKSI PENJUALAN & PENGELUARAN
CREATE TABLE IF NOT EXISTS transactions (
  id TEXT PRIMARY KEY,
  timestamp TEXT NOT NULL,
  items JSONB NOT NULL DEFAULT '[]'::jsonb,
  total_cost NUMERIC NOT NULL DEFAULT 0,
  total_revenue NUMERIC NOT NULL DEFAULT 0,
  profit NUMERIC NOT NULL DEFAULT 0,
  method TEXT NOT NULL DEFAULT 'Tunai',
  cash_paid NUMERIC DEFAULT 0,
  cash_change NUMERIC DEFAULT 0,
  customer_name TEXT DEFAULT 'Pelanggan Umum',
  customer_phone TEXT DEFAULT '',
  notes TEXT DEFAULT '',
  is_cash_out BOOLEAN DEFAULT FALSE,
  is_expense BOOLEAN DEFAULT FALSE,
  category TEXT DEFAULT '',
  amount NUMERIC DEFAULT 0,
  recipient TEXT DEFAULT '',
  cashier_name TEXT DEFAULT '',
  admin_mode TEXT DEFAULT '',
  admin_fee NUMERIC DEFAULT 0,
  base_amount NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. TABEL BUKU HUTANG / KASBON
CREATE TABLE IF NOT EXISTS debts (
  id TEXT PRIMARY KEY,
  customer_name TEXT NOT NULL,
  customer_phone TEXT DEFAULT '',
  total_amount NUMERIC NOT NULL DEFAULT 0,
  remaining_amount NUMERIC NOT NULL DEFAULT 0,
  due_date TEXT DEFAULT '',
  notes TEXT DEFAULT '',
  status TEXT DEFAULT 'Belum Lunas',
  history JSONB DEFAULT '[]'::jsonb,
  timestamp TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. TABEL RIWAYAT CICILAN HUTANG
CREATE TABLE IF NOT EXISTS debt_payments (
  id TEXT PRIMARY KEY,
  debt_id TEXT NOT NULL,
  amount NUMERIC NOT NULL DEFAULT 0,
  timestamp TEXT NOT NULL,
  method TEXT DEFAULT 'Tunai',
  cashier TEXT DEFAULT 'Kasir',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. TABEL PENGGUNA & KASIR (ROLE & PIN)
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'pegawai',
  pin TEXT NOT NULL DEFAULT '0000',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. TABEL STATUS LACI KASIR AKTIF
CREATE TABLE IF NOT EXISTS drawer (
  id TEXT PRIMARY KEY DEFAULT 'current',
  is_open BOOLEAN DEFAULT FALSE,
  opened_at TEXT,
  opened_by TEXT,
  starting_cash NUMERIC DEFAULT 0,
  notes TEXT DEFAULT '',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. TABEL RIWAYAT REKAP TUTUP KASIR (SHIFT)
CREATE TABLE IF NOT EXISTS drawer_history (
  id TEXT PRIMARY KEY,
  opened_at TEXT,
  closed_at TEXT,
  opened_by TEXT,
  closed_by TEXT,
  starting_cash NUMERIC DEFAULT 0,
  cash_sales NUMERIC DEFAULT 0,
  cash_debts NUMERIC DEFAULT 0,
  operational_expenses NUMERIC DEFAULT 0,
  tarik_tunai_out NUMERIC DEFAULT 0,
  cash_out NUMERIC DEFAULT 0,
  qris_sales NUMERIC DEFAULT 0,
  transfer_sales NUMERIC DEFAULT 0,
  expected_total NUMERIC DEFAULT 0,
  actual_cash NUMERIC DEFAULT 0,
  diff NUMERIC DEFAULT 0,
  non_cash_sales NUMERIC DEFAULT 0,
  new_debts NUMERIC DEFAULT 0,
  tx_count NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===================================================================
-- AKTIFKAN KEAMANAN ROW LEVEL SECURITY (RLS) & IZIN AKSES ANONYMOUS
-- Memungkinkan aplikasi POS web/HP membaca dan menulis data secara aman.
-- ===================================================================

ALTER TABLE konter_store ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE debts ENABLE ROW LEVEL SECURITY;
ALTER TABLE debt_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE drawer ENABLE ROW LEVEL SECURITY;
ALTER TABLE drawer_history ENABLE ROW LEVEL SECURITY;

-- Buat Kebijakan Akses Penuh untuk Anon Key
DROP POLICY IF EXISTS "Public Full Access konter_store" ON konter_store;
CREATE POLICY "Public Full Access konter_store" ON konter_store FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public Full Access products" ON products;
CREATE POLICY "Public Full Access products" ON products FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public Full Access transactions" ON transactions;
CREATE POLICY "Public Full Access transactions" ON transactions FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public Full Access debts" ON debts;
CREATE POLICY "Public Full Access debts" ON debts FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public Full Access debt_payments" ON debt_payments;
CREATE POLICY "Public Full Access debt_payments" ON debt_payments FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public Full Access users" ON users;
CREATE POLICY "Public Full Access users" ON users FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public Full Access drawer" ON drawer;
CREATE POLICY "Public Full Access drawer" ON drawer FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public Full Access drawer_history" ON drawer_history;
CREATE POLICY "Public Full Access drawer_history" ON drawer_history FOR ALL USING (true) WITH CHECK (true);

-- ===================================================================
-- AKTIFKAN FITUR REALTIME
-- Agar perubahan kasir HP langsung tampil di laptop toko tanpa refresh
-- ===================================================================

DO $$
BEGIN
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE konter_store, products, transactions, debts, debt_payments, drawer, drawer_history;
  EXCEPTION
    WHEN duplicate_object THEN
      NULL;
  END;
END $$;
