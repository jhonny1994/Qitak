create schema if not exists private;

create or replace function private.handle_message_insert_side_effects()
returns trigger
language plpgsql
security definer
set search_path = public, private
as $$
declare
  v_listing_id uuid;
  v_buyer_id uuid;
  v_seller_id uuid;
  v_recipient_id uuid;
begin
  select listing_id, buyer_id, seller_id
  into v_listing_id, v_buyer_id, v_seller_id
  from public.conversations
  where id = new.conversation_id;

  update public.conversations
  set last_message_at = new.created_at
  where id = new.conversation_id;

  if new.sender_id = v_buyer_id then
    v_recipient_id := v_seller_id;
  elsif new.sender_id = v_seller_id then
    v_recipient_id := v_buyer_id;
  else
    return new;
  end if;

  if v_recipient_id is not null then
    insert into public.notifications (
      user_id,
      type,
      data
    )
    values (
      v_recipient_id,
      'message_received',
      jsonb_build_object(
        'conversation_id', new.conversation_id,
        'listing_id', v_listing_id,
        'message_id', new.id,
        'deep_link', '/messages/thread/' || new.conversation_id
      )
    );
  end if;

  return new;
end;
$$;

revoke all on function private.handle_message_insert_side_effects() from public;

drop trigger if exists trg_messages_after_insert_side_effects on public.messages;
create trigger trg_messages_after_insert_side_effects
after insert on public.messages
for each row
execute function private.handle_message_insert_side_effects();
