class ExcludeEmptyMessagesFromConversationMessages < ActiveRecord::Migration
  def up
    sql = <<-SQL
      create or replace view conversation_messages as
        select
          messageable_type,
          messageable_id,
          content,
          null as status,
          user_id,
          created_at,
          updated_at,
          'ChatMessage' as full_object_type,
          id as full_object_id
        from chat_messages

        union all

        select
          joinable_type as messageable_type,
          joinable_id as messageable_id,
          message as content,
          status,
          user_id,
          created_at,
          updated_at,
          'JoinRequest' as full_object_type,
          id as full_object_id
        from join_requests
        where status in ('pending', 'accepted')
          and message <> ''
    SQL

    execute(sql)
  end

  def down
    sql = <<-SQL
      create or replace view conversation_messages as
        select
          messageable_type,
          messageable_id,
          content,
          null as status,
          user_id,
          created_at,
          updated_at,
          'ChatMessage' as full_object_type,
          id as full_object_id
        from chat_messages

        union all

        select
          joinable_type as messageable_type,
          joinable_id as messageable_id,
          message as content,
          status,
          user_id,
          created_at,
          updated_at,
          'JoinRequest' as full_object_type,
          id as full_object_id
        from join_requests
        where status in ('pending', 'accepted')
    SQL

    execute(sql)
  end
end
