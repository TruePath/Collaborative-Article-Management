module GoogleControllerApi
  extend ActiveSupport::Concern

  included do
    rescue_from GoogleOauthRequired, with: :google_reauthorize
  end

  def google_authorize
    cred_store = GoogleStorage.new(current_user)
    storage = Google::APIClient::Storage.new(cred_store)
    auth = storage.authorize
    if auth.nil? || (auth.expired? && auth.refresh_token.nil?)
      raise GoogleOauthRequired
    end
    auth
  end

  def google_reauthorize
    session[:return_to] = request.original_url
    scope = current_user.google_scope || "https://www.googleapis.com/auth/drive"
    auth = Signet::OAuth2::Client.new({
      :client_id => Rails.application.secrets.google_app_id,
      :client_secret => Rails.application.secrets.google_app_secret,
      :scope => scope,
      :redirect_uri => users_google_oauth2_url,
      :additional_parameters => {"include_granted_scopes" => "true"}
       })
    force_redirect(auth.authorization_uri.to_s)
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

  module ClassMethods


  end

end
