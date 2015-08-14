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
    user.google_credentials = user.google_credentials.merge(access_token.credentials)
    user.save
    user
  end

end
