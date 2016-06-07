module V1
  class UserSerializer < ActiveModel::Serializer
    attributes :id,
               :email,
               :display_name,
               :first_name,
               :last_name,
               :token,
               :avatar_url,
               :user_type

    has_one :organization
    has_one :stats

    def filter(keys)
      me? ? keys : keys - [:token, :email]
    end

    def stats
      {
          tour_count: object.tours.count,
          encounter_count: object.encounters.count
      }
    end

    def avatar_url
      UserServices::Avatar.new(user: object).thumbnail_url
    end

    def display_name
      "#{object.first_name} #{object.last_name[0, 1]}" if [object.first_name, object.last_name].compact.present?
    end

    def me?
      scope && (object.id == scope.id)
    end
  end
end