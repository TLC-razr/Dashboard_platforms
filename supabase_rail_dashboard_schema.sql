-- ЖД-дашборд: схема Supabase
-- Выполните один раз в Supabase -> SQL Editor.

create table if not exists public.rail_companies (
  id text primary key,
  name text not null,
  role text not null default 'Собственник',
  contact text not null default '',
  email text not null default '',
  phone text not null default '',
  active boolean not null default true,
  updated_at timestamptz not null default now()
);

create table if not exists public.rail_market_entries (
  id text primary key,
  report_date date not null,
  company_id text not null,
  status text not null default 'Ожидаем ответ',
  channel text not null default '',
  platform_length text not null default '',
  model text not null default '',
  qty integer not null default 0 check (qty >= 0),
  rate numeric(14,2) not null default 0 check (rate >= 0),
  location text not null default '',
  available_date date,
  vat text not null default '',
  repairs text not null default '',
  term_months integer not null default 0 check (term_months >= 0),
  comment text not null default '',
  updated_at timestamptz not null default now()
);

create index if not exists rail_market_entries_report_date_idx
  on public.rail_market_entries (report_date);
create index if not exists rail_market_entries_company_idx
  on public.rail_market_entries (company_id);

create table if not exists public.rail_daily_control (
  report_date date not null,
  company_id text not null,
  position integer not null default 0,
  updated_at timestamptz not null default now(),
  primary key (report_date, company_id)
);

create index if not exists rail_daily_control_report_date_idx
  on public.rail_daily_control (report_date);

-- Защита: доступ только авторизованным пользователям Supabase Auth.
alter table public.rail_companies enable row level security;
alter table public.rail_market_entries enable row level security;
alter table public.rail_daily_control enable row level security;

-- Явные права Data API.
revoke all on public.rail_companies from anon;
revoke all on public.rail_market_entries from anon;
revoke all on public.rail_daily_control from anon;

grant select, insert, update, delete on public.rail_companies to authenticated;
grant select, insert, update, delete on public.rail_market_entries to authenticated;
grant select, insert, update, delete on public.rail_daily_control to authenticated;

-- Политики для сотрудников, вошедших через Supabase Auth.
drop policy if exists "rail_companies_authenticated_all" on public.rail_companies;
create policy "rail_companies_authenticated_all"
on public.rail_companies
for all
to authenticated
using (true)
with check (true);

drop policy if exists "rail_entries_authenticated_all" on public.rail_market_entries;
create policy "rail_entries_authenticated_all"
on public.rail_market_entries
for all
to authenticated
using (true)
with check (true);

drop policy if exists "rail_control_authenticated_all" on public.rail_daily_control;
create policy "rail_control_authenticated_all"
on public.rail_daily_control
for all
to authenticated
using (true)
with check (true);
