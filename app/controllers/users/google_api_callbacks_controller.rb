class Users::GoogleApiCallbacksController < ApplicationController
	def google_oauth2
		cred_store = GoogleStorage.new(current_user)
    storage = Google::APIClient::Storage.new(cred_store)
 		auth = Signet::OAuth2::Client.new({
        :client_id => Rails.application.secrets.google_app_id,
        :client_secret => Rails.application.secrets.google_app_secret,
        :scope => scope,
        :redirect_uri => users_google_oauth2_url
         })
 		if request['code'] == nil
 			redirect_to(auth.authorization_uri.to_s)
 		else
 			auth.code = request['code']
 			auth.fetch_access_token!
 			storage.write_credentials(auth)
 			return_to = session[:return_to]
 			session[:return_to] = nil
 			redirect_to(return_to)
 		end
	end
end