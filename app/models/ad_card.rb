class AdCard < ActiveRecord::Base

    AD_CARD_STATUS = ['created', 'published', 'archived']
    AD_CARD_AREAS = ['National', 'Paris', 'Lyon', 'Rennes', 'Lille']

    validates_presence_of :title, :cta, :redirection_url, :targeted_area, :ranking
    validates_numericality_of :ranking

    validates_inclusion_of :status, in: AD_CARD_STATUS
    validates_inclusion_of :targeted_area, in: AD_CARD_AREAS

  end