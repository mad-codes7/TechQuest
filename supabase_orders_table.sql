-- Run this in Supabase → SQL Editor
create table if not exists public.orders (
  id            bigint generated always as identity primary key,
  created_at    timestamptz default now(),
  buyer_id      uuid references auth.users(id) on delete cascade,
  buyer_name    text,
  buyer_email   text,
  product_name  text,
  product_category text,
  quantity      int,
  unit_price    numeric,
  total_price   numeric,
  seller_email  text,
  seller_name   text,
  status        text default 'pending'
);

-- Enable RLS
alter table public.orders enable row level security;

-- Users can insert their own orders
create policy "Users can place orders"
  on public.orders for insert
  with check (auth.uid() = buyer_id);

-- Users can read their own orders
create policy "Users can view own orders"
  on public.orders for select
  using (auth.uid() = buyer_id);

-- Admins (seller) can read orders for their products
create policy "Sellers can view their orders"
  on public.orders for select
  using (true);

-- Admins can update order status
create policy "Sellers can update order status"
  on public.orders for update
  using (true);
