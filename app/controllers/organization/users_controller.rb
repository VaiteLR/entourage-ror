class Organization::UsersController < GuiController
  attr_writer :sms_notification_service, :url_shortener

  before_filter :get_user, :only => [:edit, :update, :destroy, :send_sms]

  def index
    @new_user = User.new
  end
  
  def edit
  end

  def create
    @user = User.new(user_params)
    @user.organization = @organization

    if @user.save
      redirect_to organization_users_url, notice: "L'utilisateur a été créé"
    else
      redirect_to organization_users_url, notice: "Erreur de création"
    end
  end

  def update
    if @user.update_attributes(user_params)
      redirect_to organization_users_url, notice: "L'utilisateur a été sauvegardé"
    else
      flash[:notice] = "Erreur de modification"
      render action: "edit"
    end
  end

  def destroy
    @user.destroy
    redirect_to organization_users_url, notice: "L'utilisateur a bien été supprimé"
  end
  
  def send_sms
    link = url_shortener.shorten(apps_url)
    sms_notification_service.send_notification(@user.phone, "Bienvenue sur Entourage. Votre code est #{@user.sms_code}. Retrouvez l'application ici : #{link} .")
    head 200
  end
  
  private
  
  def get_user
    @user = User.find_by id: params[:id]
    if @user.nil?
      head :not_found
    else
      if @user.organization != @organization
        head :forbidden
      end
    end
  end
  
  def user_params
    params.require(:user).permit(:first_name, :last_name, :phone, :email, :manager)
  end
  
  def sms_notification_service
    @sms_notification_service ||= SmsNotificationService.new
  end
  
  def url_shortener
    @url_shortener ||= ShortURL
  end
  
end