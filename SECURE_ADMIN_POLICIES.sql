-- JUBO security hardening. Run once in Supabase SQL Editor after the first setup script.
-- This uses the admin account you already added to public.jubo_admins.

create or replace function public.jubo_is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.jubo_admins
    where user_id = auth.uid()
  );
$$;

revoke all on function public.jubo_is_admin() from public;
grant execute on function public.jubo_is_admin() to authenticated;

-- Public visitors may read the current campaign and aggregate vote totals.
grant select on public.jubo_campaign to anon, authenticated;
grant select on public.jubo_vote_counts to anon, authenticated;

-- Authenticated users may attempt campaign writes, but RLS allows only allow-listed admins.
grant insert, update, delete on public.jubo_campaign to authenticated;

drop policy if exists "JUBO admins can update campaign" on public.jubo_campaign;
drop policy if exists "JUBO admins manage campaign" on public.jubo_campaign;
create policy "JUBO admins manage campaign" on public.jubo_campaign
  for all to authenticated
  using (public.jubo_is_admin())
  with check (public.jubo_is_admin());

-- Keep raw voter records and admin allowlist inaccessible to browser clients.
revoke all on public.jubo_votes from anon, authenticated;
revoke all on public.jubo_admins from anon, authenticated;
revoke insert, update, delete on public.jubo_vote_counts from anon, authenticated;

-- The vote RPC is intentionally callable by public visitors; it validates the selected flavour,
-- records one vote per browser-generated voter UUID, and only exposes aggregate counts.
revoke all on function public.jubo_cast_vote(uuid, text) from public;
grant execute on function public.jubo_cast_vote(uuid, text) to anon, authenticated;

-- Only allow-listed admins may reset all votes.
create or replace function public.jubo_reset_votes()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.jubo_is_admin() then
    raise exception 'Admin access required';
  end if;
  delete from public.jubo_votes;
  update public.jubo_vote_counts set count = 0;
end;
$$;
revoke all on function public.jubo_reset_votes() from public;
grant execute on function public.jubo_reset_votes() to authenticated;
