module UserServices
  class SMSSender
    def initialize(user:)
      @user = user
    end

    def send_welcome_sms!
      link = Rails.env.test? ? "http://foo.bar" : url_shortener.shorten("https://play.google.com/apps/testing/social.entourage.android")
      message = "Bienvenue sur Entourage. Votre code est #{user.sms_code}. Retrouvez l'application ici : #{link} ."
      sms_notification_service.send_notification(user.phone, message)
    end

    private
    attr_reader :user

    def sms_notification_service
      @sms_notification_service ||= SmsNotificationService.new
    end

    def url_shortener
      @url_shortener ||= ShortURL
    end
  end
end