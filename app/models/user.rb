class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]

  has_many :libraries, :inverse_of => :user
  serialize :google_credentials, Hash

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
    user.uid = access_token.uid
    user.google_credentials = user.google_credentials.merge(access_token.credentials)
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

end
