# require 'google/api_client'
# require 'google/api_client/auth/installed_app'
# require 'google/api_client/auth/storage'
# require 'google/api_client/auth/storages/file_store'


class GoogleStorage

  def initialize(user)
    @user=user
  end

  def load_credentials
    @user.google_credentials
  end

  def write_credentials(credentials_hash)
    @user.google_credentials = credentials_hash
    @user.save
  end
end



class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]

  has_many :libraries, :inverse_of => :user
  has_many :file_managers, :inverse_of => :user
  serialize :google_credentials, Hash
  serialize :services, Set
  delegate :drive_file_managers, to: :file_managers

  def self.from_omniauth(access_token)
    info = access_token.info
    user = User.where(:email => info["email"]).first

    unless user
        user = User.create(name: info["name"],
           email: info["email"],
           password: Devise.friendly_token[0,20]
        )
    end
    user.provider = access_token.provider
    user.google_uid = access_token.uid
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
    creds['authorization_uri'] = 'https://accounts.google.com/o/oauth2/auth'
    creds['token_credential_uri'] = "https://accounts.google.com/o/oauth2/token"
    creds['client_id'] = Rails.application.secrets.google_app_id
    creds['client_secret'] = Rails.application.secrets.google_app_secret
    user.google_credentials = user.google_credentials.merge(creds)
    user.save
    user
  end

  def self.new_with_session(params, session) #may or may not be needed
    super.tap do |user|
      if info = session["devise.google_data"].info #&& session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = info["email"] if user.email.blank?
      end
    end
  end

  def default_google_scope
    return [ "https://www.googleapis.com/auth/drive" ]
  end

  def google_scope
    self.drive_file_managers.inject(default_google_scope) { |combine, cur|
      (combine + cur.scope).uniq
    }
  end





end
