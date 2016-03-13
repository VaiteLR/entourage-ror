class PushNotificationService
  def initialize(android_notification_service = nil, ios_notification_service = nil)
    @android_notification_service = android_notification_service
    @ios_notification_service = ios_notification_service
  end


  def send_notification(sender, object, content, users)
    user_applications = UserApplication.where(user_id: users.map(&:id))

    android_device_ids = user_applications.where(device_family: UserApplication::ANDROID).pluck(:push_token)
    android_notification_service.send_notification sender, object, content, android_device_ids
    
    ios_device_ids = user_applications.where(device_family: UserApplication::IOS).pluck(:push_token)
    ios_notification_service.send_notification sender, object, content, ios_device_ids
  end
  
  private
  
  def android_notification_service
    @android_notification_service || AndroidNotificationService.new
  end
  
  def ios_notification_service
    @ios_notification_service || IosNotificationService.new
  end
end
