module Admin
  class AdCardsController < Admin::BaseController
    layout 'admin_large'
    before_action :get_available_rankings, only: [:new, :edit]

    def index
      @ad_cards = AdCard.all.order(:ranking)
    end

    def new
      @ad_card = AdCard.new
      @form = AdCardImageUploader
    end

    def create
      @ad_card = AdCard.new(ad_card_params)
      @ad_card.status = 'created'
      AdCardImageUploader.handle_success(params[:image])

      if @ad_card.save
        redirect_to [:admin, @ad_card]
      else
        render :new
      end
    end

    def show
      redirect_to edit_admin_ad_card_path(params[:id])
    end

    def edit
      @ad_card = AdCard.find(params[:id])
      @form = AdCardImageUploader
    end

    def update
      @ad_card = AdCard.find(params[:id])

      @ad_card.assign_attributes(ad_card_params)

      if @ad_card.save
        redirect_to [:admin, @ad_card], notice: "Carte annonce mise à jour"
      else
        render :edit
      end
    end

    def archive
      @ad_card = AdCard.find(params[:id])
      @ad_card.status = 'archived'
      if @ad_card.ranking < 6
        @ad_card.ranking = @ad_card.id + 5
      end

      if @ad_card.save
        redirect_to admin_ad_cards_path, notice: "Carte annonce archivée"
      else
        redirect_to [:admin, @ad_card], error: "Erreur"
      end
    end

    def destroy
      @ad_card = AdCard.find(params[:id])

      if @ad_card.destroy
        redirect_to admin_ad_cards_path, notice: "Carte annonce supprimée"
      else
        redirect_to [:admin, @ad_card], error: "Erreur"
      end
    end

    def get_available_rankings
      @available_rankings = [1,2,3,4,5]
      if params && params[:id]
        @ad_card = AdCard.find(params[:id])
        if @ad_card.present? && @ad_card.ranking > 5
          @available_rankings << @ad_card.ranking
        end
      end
    end

    private

    def ad_card_params
      params.require(:ad_card).permit(
        :title, :sub_title, :cta, :redirection_url, :targeted_area, :ranking, :image
      )
    end
  end
end
