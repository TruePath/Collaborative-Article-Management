require 'google/apis/oauth2_v2'
require 'signet/oauth_2/client'
require 'google/apis/drive_v2'




class FileManager < ActiveRecord::Base
	#kind:string user:references count:integer
  belongs_to :user, :inverse_of => :file_managers
  serialize :scope, Array
  serialize :auth_data, Hash
  scope :drive_file_managers, -> { where(type: 'DriveFileManager') }

  def destroy_duplicate  #Called if we accidently create a second filemanager for same account
  	if self.account && dup = FileManager.where(type: self.type, account: self.account).where.not(id: self.id).first
 			dup.scope = dup.scope.concat(self.scope).uniq
 			dup.auth_data = dup.auth_data.merge(self.auth_data)
 			dup.save
 			self.destroy
  	end
  end


end


class DriveFileManager < FileManager
	before_create :set_default_scope
	Oauth2 = Google::Apis::Oauth2V2 # Alias the module

	AUTHORIZATION_URI = 'https://accounts.google.com/o/oauth2/auth'
	TOKEN_CREDENTIAL_URI = 'https://accounts.google.com/o/oauth2/token'

	def self.manager_for_account(email)
		manager = DriveFileManager.where(type: 'DriveFileManager', account: email).first
		manager = DriveFileManager.create(account: email) unless manager
		manager
	end

	def set_account
    service = Oauth2::Oauth2Service.new
    service.authorization = self.auth_client
    userinfo = service.get_userinfo
    self.account = userinfo.email
	end

	def auth_client(redirect_uri = Rails.application.routes.url_helpers.oauth2_callback_url)
		@auth_client = Signet::OAuth2::Client.new(auth_data) unless @auth_client
		@auth_client.update!(
			  :client_id => Rails.application.secrets.google_app_id,
        :client_secret => Rails.application.secrets.google_app_secret,
        :scope => scope,
        :redirect_uri => redirect_uri,
        :authorization_uri     => AUTHORIZATION_URI,
        :token_credential_uri  => TOKEN_CREDENTIAL_URI
			)
		return @auth_client
	end

	def auth_uri(redirect_uri = Rails.application.routes.url_helpers.oauth2_callback_url)
		self.state = (('a'..'z').to_a+('A'..'Z').to_a+(0..9).to_a).shuffle[0,8].join
		self.save
		return self.auth_client(redirect_uri).authorization_uri(:state => self.state).to_s
	end

	def accept_callback(code, request_state)
		raise "State Parameter Not Preserved" unless request_state == self.state
		client = self.auth_client
		client.code = code
		client.fetch_access_token!
		set_account unless self.account
		self.update_auth_data(client)
		self.save
		self.destroy_duplicate
	end

	def update_auth_data(authorization)
		self.auth_data =	{
		      :access_token          => authorization.access_token,
          :authorization_uri     => AUTHORIZATION_URI,
          :client_id             => authorization.client_id,
          :client_secret         => authorization.client_secret,
          :expires_in            => authorization.expires_in,
          :refresh_token         => authorization.refresh_token,
          :token_credential_uri  => TOKEN_CREDENTIAL_URI,
          :issued_at             => authorization.issued_at.to_i
      }
	end

	def update_from_omniauth(access_token)
		creds = Hash.new
    creds['access_token'] = access_token.credentials['token']
    creds['refresh_token'] = access_token.credentials['refresh_token'] if access_token.credentials.has_key?('refresh_token')
    creds['expires_at'] = access_token.credentials['expires_at']
    if (access_token.credentials.has_key?('expires_at') && ! access_token.credentials.has_key?('expires_in'))
      creds['issued_at'] = Time.now.to_i
      creds['expires_in'] = creds['expires_at'] - creds['issued_at']
    else
      creds['expires_in'] = access_token.credentials['expires_in']
      creds['issued_at'] = access_token.credentials['issued_at']
    end
    creds['authorization_uri'] = AUTHORIZATION_URI
    creds['token_credential_uri'] = TOKEN_CREDENTIAL_URI
    creds['client_id'] = Rails.application.secrets.google_app_id
    creds['client_secret'] = Rails.application.secrets.google_app_secret
    self.auth_data = self.auth_data.merge(creds)
    @auth_client = Signet::OAuth2::Client.new(auth_data)
		@auth_client.update!(
			  :client_id => Rails.application.secrets.google_app_id,
        :client_secret => Rails.application.secrets.google_app_secret,
        :scope => scope,
        :redirect_uri => users_google_oauth2_url
			)
	end

	def set_default_scope
		self.scope = ["email", "profile", "https://www.googleapis.com/auth/drive"] if self.scope.empty?
	end


end