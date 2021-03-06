module Api
  module V1
    class EntouragesController < Api::V1::BaseController
      before_action :set_entourage_or_handle_conversation_uuid, only: [:show]
      before_action :set_entourage, only: [:update, :read, :one_click_update, :report]
      skip_before_filter :authenticate_user!, only: [:one_click_update]
      allow_anonymous_access only: [:show]

      def index
        finder = EntourageServices::EntourageFinder.new(user: current_user,
                                                        status: params[:status],
                                                        type: params[:type],
                                                        latitude: params[:latitude],
                                                        longitude: params[:longitude],
                                                        distance: params[:distance],
                                                        page: params[:page],
                                                        per: per,
                                                        atd: params[:atd])
        render json: finder.entourages, each_serializer: ::V1::EntourageSerializer, scope: {user: current_user}
      end

      #curl -H "Content-Type: application/json" "http://localhost:3000/api/v1/entourages/951.json?token=e4fdc865bc7a91c34daea849e7d73349&distance=123.45&feed_rank=2"
      def show
        ensure_permission! :can_read_public_content?
        EntourageServices::EntourageDisplayService.new(entourage: @entourage, user: current_user_or_anonymous, params: params).view
        is_onboarding, mp_params = Onboarding::V1.entourage_metadata(@entourage)
        mixpanel.track("Displayed Entourage", mp_params) unless current_user_or_anonymous.anonymous?
        include_last_message = params[:include_last_message] == 'true'
        render json: @entourage, serializer: ::V1::EntourageSerializer, scope: {user: current_user_or_anonymous, include_last_message: include_last_message}
      end

      #curl -H "Content-Type: application/json" -X POST -d '{"entourage": {"title": "entourage1", "entourage_type": "ask_for_help", "description": "lorem ipsum", "location": {"latitude": 37.4224764, "longitude": -122.0842499}}, "token": "azerty"}' "http://localhost:3000/api/v1/entourages.json"
      def create
        entourage_builder = EntourageServices::EntourageBuilder.new(params: entourage_params, user: current_user)
        entourage_builder.create do |on|
          on.success do |entourage|
            mixpanel.track("Displayed Entourage")
            mixpanel.track("Requested to join Entourage")
            mixpanel.track("Wrote Message in Entourage")
            mixpanel.track("Created Entourage")
            render json: entourage, status: 201, serializer: ::V1::EntourageSerializer, scope: {user: current_user}
          end

          on.failure do |entourage|
            render json: {message: 'Could not create entourage', reasons: entourage.errors.full_messages}, status: 400
          end
        end
      end

      def update
        return render json: {message: 'unauthorized'}, status: :unauthorized if @entourage.user != current_user

        unless ['action', 'outing', 'group'].include?(@entourage.group_type)
          return render json: {message: "This operation is not available for groups of type '#{@entourage.group_type}'"}, status: :bad_request
        end

        entourage_builder = EntourageServices::EntourageBuilder.new(params: entourage_params, user: current_user)
        entourage_builder.update(entourage: @entourage) do |on|
          on.success do |entourage|
            render json: @entourage, status: 200, serializer: ::V1::EntourageSerializer, scope: {user: current_user}
          end

          on.failure do |entourage|
            render json: {message: 'Could not update entourage', reasons: @entourage.errors.full_messages}, status: 400
          end
        end
      end


      #curl -H "Content-Type: application/json" -X PUT "http://localhost:3000/api/v1/entourages/1184/read.json?token=azerty"
      def read
        @entourage.join_requests
                  .accepted
                  .where(user: current_user)
                  .update_all(last_message_read: DateTime.now)
        head :no_content
      end

      def one_click_update
        @success = false

        if SignatureService.validate(@entourage.id, params[:signature])
          service = EntourageServices::EntourageBuilder.new(
            params: {status: :closed, outcome: {success: true}},
            user: @entourage.user
          )
          service.update(entourage: @entourage) do |on|
            on.success { @success = true }
          end
        end

        render layout: 'landing'
      end

      def report
        message = entourage_report_params[:message]
        if message.blank?
          render json: { code: 'CANNOT_REPORT_ENTOURAGE' }, status: :bad_request
          return
        end

        reporting_user = current_user_or_anonymous
        reporting_user = reporting_user.token if reporting_user.anonymous?

        AdminMailer.group_report(
          reported_group: @entourage,
          reporting_user: reporting_user,
          message:        message
        ).deliver_later

        head :created
      end

      private

      def entourage_params
        metadata_keys = params.dig(:entourage, :metadata).try(:keys) || []
        params.require(:entourage).permit(:group_type, {location: [:longitude, :latitude]}, :title, :entourage_type, :display_category, :status, :description, :category, :public, {outcome: [:success]}, {metadata: metadata_keys}, :recipient_consent_obtained)
      end

      def entourage_report_params
        params.require(:entourage_report).permit(:message)
      end

      def set_entourage
        @entourage = Entourage.find_by_id_or_uuid(params[:id])
      end

      def set_entourage_or_handle_conversation_uuid
        set_entourage and return unless ConversationService.list_uuid?(params[:id])

        if current_user_or_anonymous.anonymous?
          return render json: {
            message: "Anonymous user can't access this resource.",
            code: 'ANONYMOUS_USER_AUTHENTICATION_REQUIRED'
          }, status: :unauthorized
        end

        participant_ids = ConversationService.participant_ids_from_list_uuid(params[:id], current_user: current_user)
        raise ActiveRecord::RecordNotFound unless participant_ids.include?(current_user.id.to_s)
        hash_uuid = ConversationService.hash_for_participants(participant_ids)
        @entourage =
          Entourage.findable.find_by(uuid_v2: hash_uuid) ||
          ConversationService.build_conversation(participant_ids: participant_ids)
      end

      def ensure_permission! permission
        has_permission = GroupAccessService.send(
          permission,
          user: current_user_or_anonymous,
          group: @entourage
        )
        raise ActiveRecord::RecordNotFound unless has_permission
      end
    end
  end
end
