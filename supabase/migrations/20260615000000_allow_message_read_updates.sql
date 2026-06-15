drop policy if exists "Conversation participants can mark received messages read" on public.messages;
create policy "Conversation participants can mark received messages read"
  on public.messages for update
  using (
    conversation_id in (
      select id from public.conversations
      where buyer_id = auth.uid() or seller_id = auth.uid()
    )
  )
  with check (
    sender_id <> auth.uid()
    and conversation_id in (
      select id from public.conversations
      where buyer_id = auth.uid() or seller_id = auth.uid()
    )
  );
