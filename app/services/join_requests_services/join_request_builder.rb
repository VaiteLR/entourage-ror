module JoinRequestsServices
  class JoinRequestBuilder
    def initialize(joinable:, user:)
      @joinable = joinable
      @user = user
      @callback = Callback.new
    end

    def create
      yield callback if block_given?

      join_request = JoinRequest.new(joinable: joinable, user: user)
      if join_request.save
        notify_members(join_request.joinable_type)
        callback.on_create_success.try(:call, join_request)
      else
        callback.on_create_failure.try(:call, join_request)
      end
    end

    private
    attr_reader :joinable, :callback, :user

    def notify_members(type)
      recipients = joinable.members.includes(:join_requests).where(join_requests: {status: "accepted"})
      PushNotificationService.new.send_notification(user.full_name,
                                                    "Demande en attente",
                                                    "Un nouveau membre souhaite rejoindre votre maraude",
                                                    recipients,
                                                    {joinable_id: joinable.id,
                                                     joinable_type: type,
                                                     type: "NEW_JOIN_REQUEST",
                                                     user_id: user.id})
    end
  end
end