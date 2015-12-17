json.tours do
  json.array!(@presenters) do |presenter|
    json.id presenter.id
    json.tour_type presenter.tour_type
    json.status presenter.status
    json.vehicle_type presenter.vehicle_type
    json.distance presenter.length
    json.start_time presenter.start_time
    json.end_time presenter.end_time
    json.organization_name presenter.organization_name
    json.organization_description presenter.organization_description
    json.user_id presenter.user_id
    json.tour_points do
      json.array!(presenter.tour_points) do |coordinate|
        json.latitude coordinate[:lat]
        json.longitude coordinate[:long]
        json.passing_time presenter.start_time
      end
    end
  end
end