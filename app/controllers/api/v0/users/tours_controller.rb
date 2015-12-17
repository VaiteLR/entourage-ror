module Api
  module V0
    module Users
      class ToursController < Api::V0::BaseController
        before_action :set_user

        def index
          page = params[:page] || 1
          per = [(params[:per].try(:to_i) || 25), 25].min
          tours = @user.tours.page(page).per(per)
          @presenters = TourCollectionPresenter.new(tours: tours)
          render status: 200
        end

        private

        def set_user
          @user = User.find(params[:user_id])
        end
      end
    end
  end
end

