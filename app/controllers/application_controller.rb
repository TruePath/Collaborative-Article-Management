class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

	before_filter :configure_permitted_parameters, if: :devise_controller?
	after_filter :flash_to_headers
  rescue_from NotAuthorized, with: :user_not_authorized

  add_flash_types :error, :success

  # Make sure we don't render a layout if xhr

  layout proc { false if request.xhr? }


  def flash_to_headers
      return unless request.xhr?
      if flash_message
        response.headers['X-Message'] = flash_message
        response.headers["X-Message-Type"] = flash_type.to_s

        flash.discard # don't want the flash to appear when you reload page
      end
  end

  def google_authorize
    cred_store = GoogleStorage.new(current_user)
    storage = Google::APIClient::Storage.new(cred_store)
    auth = storage.authorize
    if auth.nil? || (auth.expired? && auth.refresh_token.nil?)
      session[:return_to] = request.original_url
      scope = current_user.google_scope || "email, profile, https://www.googleapis.com/auth/drive"
      auth = Signet::OAuth2::Client.new({
        :client_id => Rails.application.secrets.google_app_id,
        :client_secret => Rails.application.secrets.google_app_secret,
        :scope => scope,
        :redirect_uri => users_google_oauth2_url
         })
      redirect_to(auth.authorization_uri.to_s)
      # storage.write_credentials(auth)
    end
    auth
  end

  def google_client
    return @client if @client
    @client = Google::APIClient.new(:application_name => "Reference Manager")
    @client.authorization = google_authorize
    return @client
  end

  def drive_api
    google_client.discovered_api('drive', 'v2')
  end


  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:account_update) << :name << :description
  end


  private

  def user_not_authorized
    flash[:error] = "You don't have access to this section."
    if request.xhr?
      render nothing: true
    else
      redirect_to :back
    end
  end

  def flash_message
      [:error, :alert, :notice, :success].each do |type|
          return flash[type] unless flash[type].blank?
      end
      return false
  end

  def flash_type
      [:error, :alert, :notice, :success].each do |type|
          return type unless flash[type].blank?
      end
  end

end
