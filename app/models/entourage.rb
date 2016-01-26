class Entourage < ActiveRecord::Base
  belongs_to :user
  has_many :entourages_users
  has_many :members, through: :entourages_users, source: :user

  validates_presence_of :status, :title, :entourage_type, :user_id, :latitude, :longitude, :number_of_people
  validates_inclusion_of :status, in: ['open', 'closed']
  validates_inclusion_of :entourage_type, in: ['ask_for_help']
end
