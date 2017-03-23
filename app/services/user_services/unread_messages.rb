module UserServices
  class UnreadMessages
    def initialize(user:)
      @user = user
    end

    def number_of_unread_messages
      user.chat_messages
          .joins("INNER JOIN join_requests ON join_requests.joinable_id = messageable_id AND joinable_type=messageable_type AND status='accepted'")
          .where("chat_messages.created_at > join_requests.last_message_read")
          .count
    end

    private
    attr_reader :user
  end
end