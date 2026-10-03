-- ============================================================
-- ERA PRA ONTEM — Supabase Cloud Sync
-- Execute este arquivo UMA VEZ no SQL Editor do Supabase.
-- ============================================================

create table if not exists public.teacher_app_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  state jsonb not null default '{}'::jsonb,
  version bigint not null default 1,
  updated_at timestamptz not null default now(),
  client_id text
);

create table if not exists public.teacher_app_state_versions (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  state jsonb not null,
  version bigint not null,
  saved_at timestamptz not null default now()
);

create index if not exists teacher_app_state_versions_user_saved_idx
  on public.teacher_app_state_versions(user_id, saved_at desc);

alter table public.teacher_app_state enable row level security;
alter table public.teacher_app_state_versions enable row level security;

-- Princípio do menor privilégio:
revoke all on table public.teacher_app_state from anon, authenticated;
revoke all on table public.teacher_app_state_versions from anon, authenticated;

grant select, insert, update on table public.teacher_app_state to authenticated;
grant select on table public.teacher_app_state_versions to authenticated;

-- Cada usuário só acessa sua própria linha principal.
drop policy if exists "teacher_state_select_own" on public.teacher_app_state;
create policy "teacher_state_select_own"
on public.teacher_app_state
for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "teacher_state_insert_own" on public.teacher_app_state;
create policy "teacher_state_insert_own"
on public.teacher_app_state
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "teacher_state_update_own" on public.teacher_app_state;
create policy "teacher_state_update_own"
on public.teacher_app_state
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

-- Backups: o usuário pode ler apenas os próprios.
drop policy if exists "teacher_versions_select_own" on public.teacher_app_state_versions;
create policy "teacher_versions_select_own"
on public.teacher_app_state_versions
for select
to authenticated
using ((select auth.uid()) = user_id);

-- Antes de cada atualização:
-- 1) preserva a versão anterior;
-- 2) incrementa a versão;
-- 3) usa o horário do servidor;
-- 4) mantém somente os 20 backups mais recentes.
create or replace function public.teacher_app_state_before_update()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.state is distinct from old.state then
    insert into public.teacher_app_state_versions(user_id, state, version, saved_at)
    values(old.user_id, old.state, old.version, old.updated_at);

    new.version := old.version + 1;
    new.updated_at := now();

    delete from public.teacher_app_state_versions
    where user_id = old.user_id
      and id not in (
        select id
        from public.teacher_app_state_versions
        where user_id = old.user_id
        order by saved_at desc, id desc
        limit 20
      );
  else
    new.version := old.version;
    new.updated_at := old.updated_at;
  end if;

  return new;
end;
$$;

revoke all on function public.teacher_app_state_before_update() from public, anon, authenticated;

drop trigger if exists trg_teacher_app_state_before_update on public.teacher_app_state;
create trigger trg_teacher_app_state_before_update
before update on public.teacher_app_state
for each row
execute function public.teacher_app_state_before_update();
