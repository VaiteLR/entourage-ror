module Api
  module V1
    class EntouragesController < Api::V1::BaseController
      before_action :set_entourage, only: [:show, :update]

      def index
        entourages = current_user.entourages.page(params[:page]).per(params[:per])
        render json: entourages, each_serializer: ::V1::EntourageSerializer
      end

      def show
        render json: @entourage, serializer: ::V1::EntourageSerializer
      end

      def create
        entourage = Entourage.new(entourage_params)
        entourage.user = current_user
        if entourage.save
          EntouragesUser.create(user: current_user, entourage: entourage)
          render json: entourage, status: 201, serializer: ::V1::EntourageSerializer
        else
          render json: {message: 'Could not create entourage', reasons: entourage.errors.full_messages}, status: 400
        end
      end

      def update
        return render json: {message: 'unauthorized'}, status: :unauthorized if @entourage.user != current_user

        if @entourage.update(entourage_params)
          render json: @entourage, status: 201, serializer: ::V1::EntourageSerializer
        else
          render json: {message: 'Could not update entourage', reasons: @entourage.errors.full_messages}, status: 400
        end
      end

      private

      def entourage_params
        params.require(:entourage).permit(:longitude, :latitude, :title, :entourage_type, :status)
      end

      def set_entourage
        @entourage = Entourage.find(params[:id])
      end
    end
  end
end