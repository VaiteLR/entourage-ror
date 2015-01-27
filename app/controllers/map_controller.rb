class MapController < ApplicationController

  def index
  	pois_limit = params[:limit].nil? ? 45 : params[:limit]
    @categories = Category.all
    if(params.has_key?(:longitude) && params.has_key?(:latitude) && params.has_key?(:radius))
      @pois = Poi.near([params[:latitude], params[:longitude]], params[:radius], :units => :km).order(:id).limit(pois_limit)
    else
      @pois = Poi.all.order(:id).limit(pois_limit)
    end
    @encounters = Encounter.all.includes(:user)
  end

end
