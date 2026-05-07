begin;

with ranked as (
  select
    id,
    row_number() over (
      partition by user_id
      order by created_at desc nulls last, id desc
    ) as rn
  from public.reviews
  where user_id is not null
)
delete from public.reviews r
using ranked d
where r.id = d.id
  and d.rn > 1;

create unique index if not exists reviews_user_id_unique
  on public.reviews (user_id)
  where user_id is not null;

commit;
