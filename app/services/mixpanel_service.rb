class MixpanelService
  def initialize distinct_id:, default_properties:, event_prefix: nil
    @distinct_id = distinct_id
    @default_properties = default_properties.stringify_keys
    @event_prefix = event_prefix
  end

  def track event, properties={}
    client.track(
      @distinct_id,
      [@event_prefix, event].compact.join(" / "),
      @default_properties.merge(properties)
    )
  end

  def set properties
    client.people.set(
      @distinct_id,
      properties,
      @default_properties['ip'] || '0'
    )
  end

  def set_once properties
    client.people.set_once(
      @distinct_id,
      properties,
      @default_properties['ip'] || '0'
    )
  end

  def sync_changes user, props
    changes = {}
    (user.previous_changes.keys & props.keys).each do |changed_attr|
      changes[props[changed_attr]] = user[changed_attr]
    end
    if changes.any?
      set(changes)
    end
  end

  def client
    Rails.application.config.mixpanel
  end
end
