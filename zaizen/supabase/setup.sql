-- Supabase SQL Editor da shu skriptni to'liq ishga tushiring.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  full_name text,
  avatar_url text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.profiles add column if not exists created_at timestamptz default now();
alter table public.profiles enable row level security;

drop policy if exists "profiles read own" on public.profiles;
create policy "profiles read own"
  on public.profiles for select
  using (auth.uid() = id);

drop policy if exists "profiles upsert own" on public.profiles;
create policy "profiles upsert own"
  on public.profiles for insert
  with check (auth.uid() = id);

drop policy if exists "profiles update own" on public.profiles;
create policy "profiles update own"
  on public.profiles for update
  using (auth.uid() = id);

drop policy if exists "profiles delete own" on public.profiles;
create policy "profiles delete own"
  on public.profiles for delete
  using (auth.uid() = id);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name, avatar_url)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', ''),
    new.raw_user_meta_data->>'avatar_url'
  )
  on conflict (id) do update
    set email = excluded.email,
        full_name = coalesce(nullif(excluded.full_name, ''), public.profiles.full_name),
        avatar_url = coalesce(excluded.avatar_url, public.profiles.avatar_url),
        updated_at = now();
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'zaizen',
  'zaizen',
  true,
  5242880,
  array['image/jpeg','image/jpg','image/png','image/webp','image/gif','image/heic','image/heif']
)
on conflict (id) do update
  set public = true,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "zaizen public read" on storage.objects;
create policy "zaizen public read"
  on storage.objects for select
  using (bucket_id = 'zaizen');

drop policy if exists "zaizen own write" on storage.objects;
create policy "zaizen own write"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'zaizen'
    and split_part(name, '/', 1) = auth.uid()::text
  );

drop policy if exists "zaizen own update" on storage.objects;
create policy "zaizen own update"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'zaizen'
    and split_part(name, '/', 1) = auth.uid()::text
  )
  with check (
    bucket_id = 'zaizen'
    and split_part(name, '/', 1) = auth.uid()::text
  );

drop policy if exists "zaizen own delete" on storage.objects;
create policy "zaizen own delete"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'zaizen'
    and split_part(name, '/', 1) = auth.uid()::text
  );

create or replace function public.delete_own_account()
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  begin
    delete from storage.objects
    where bucket_id = 'zaizen'
      and split_part(name, '/', 1) = uid::text;
  exception when others then
    null;
  end;

  delete from public.profiles where id = uid;
  delete from auth.users where id = uid;

  return json_build_object('ok', true, 'id', uid);
end;
$$;

alter function public.delete_own_account() owner to postgres;
revoke all on function public.delete_own_account() from public;
revoke all on function public.delete_own_account() from anon;
grant execute on function public.delete_own_account() to authenticated;
