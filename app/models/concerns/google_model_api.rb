module GoogleModelApi
  extend ActiveSupport::Concern

  def google_authorize
    cred_store = GoogleStorage.new(current_user)
    storage = Google::APIClient::Storage.new(cred_store)
    auth = storage.authorize
    if auth.nil? || (auth.expired? && auth.refresh_token.nil?)
      raise GoogleOauthRequired
    end
    auth
  end

  module ClassMethods


  end

end
