class ModerationArea < ActiveRecord::Base
  belongs_to :moderator, class_name: :User

  def departement_slug
    self.class.departement_slug(departement)
  end

  def name_with_departement
    case departement
    when '*', '_'
      name
    else
      "#{name} (#{departement})"
    end
  end

  def short_name
    case departement
    when '*'
      'HZ'
    when '_'
      'SZ'
    else
      departement
    end
  end

  def self.departement_slug departement
    case departement
    when '*'
      :hors_zone
    when '_'
      :sans_zone
    when /\A\d\d\z/
      "dep_#{departement}".to_sym
    else
      raise "Unhandled departement #{departement.inspect}"
    end
  end

  def self.no_zone
    new(name: "Sans zone", departement: "_")
  end

  def self.all_with_no_zone
    all.order(:id) + [no_zone]
  end

  def self.all_slugs
    (pluck(:departement) + [no_zone.departement]).map { |d| ModerationArea.departement_slug(d) }
  end

  def self.by_slug
    Hash[all_with_no_zone.map { |a| [a.departement_slug, a] }]
  end
end
