module Onboarding
  module ChatMessagesService
    MIN_DELAY = 2.hours
    ACTIVE_DAYS = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
    ACTIVE_HOURS = '09:00'..'18:30'

    def self.deliver_welcome_message
      now = Time.zone.now
      return unless now.strftime('%A').in?(ACTIVE_DAYS)
      return unless now.strftime('%H:%M').in?(ACTIVE_HOURS)

      user_ids = User
        .where(community: :entourage, deleted: false)
        .with_event('onboarding.profile.first_name.entered', :name_entered)
        .with_event('onboarding.profile.postal_code.entered', :postal_code_entered)
        .with_event('onboarding.profile.goal.entered', :goal_entered)
        .without_event('onboarding.chat_messages.welcome.sent')
        .without_event('onboarding.chat_messages.welcome.skipped')
        .where("greatest(name_entered.created_at, postal_code_entered.created_at, goal_entered.created_at) <= ?", MIN_DELAY.ago)
        .pluck(:id)

      User.where(id: user_ids).where("goal is not null").find_each do |user|
        begin
          Raven.user_context(id: user&.id)

          moderation_area = ModerationServices.moderation_area_for_user(user)
          author = moderation_area.moderator

          participant_ids = [author.id, user.id]

          conversation_uuid = ConversationService.hash_for_participants(participant_ids, validated: false)
          conversation = Entourage.find_by(uuid_v2: conversation_uuid)

          if conversation
            join_request = JoinRequest.find_by(joinable: conversation, user: author, status: :accepted)
            chat_message_exists = conversation.chat_messages.where(message_type: :text).exists?
          else
            conversation = ConversationService.build_conversation(participant_ids: participant_ids)
            join_request = conversation.join_requests.to_a.find { |r| r.user_id == author.id }
            chat_message_exists = false
          end

          if chat_message_exists
            Event.track('onboarding.chat_messages.welcome.skipped', user_id: user.id)
            return
          end

          messages = [
            moderation_area["welcome_message_1_#{user.goal}"],
            moderation_area["welcome_message_2_#{user.goal}"]
          ].map(&:presence)

          first_name = UserPresenter.format_first_name user.first_name

          messages.each do |message|
            message = message.gsub(/\{\{\s*first_name\s*\}\}/, first_name)

            builder = ChatServices::ChatMessageBuilder.new(
              user: author,
              joinable: conversation,
              join_request: join_request,
              params: {content: message}
            )

            success = true
            builder.create do |on|
              on.failure do |message|
                success = false
                raise ActiveRecord::RecordNotSaved.new("Failed to save the record", message)
              end
            end

            if success
              Event.track('onboarding.chat_messages.welcome.sent', user_id: user.id)
              join_request.update_column(:archived_at, Time.zone.now)
            end
          end

        rescue => e
          Raven.capture_exception(e)
        end
      end
    end
  end
end
