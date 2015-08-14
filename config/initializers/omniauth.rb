# Rails.application.config.middleware.use OmniAuth::Builder do
#   provider :google_oauth2, Rails.application.secrets.google_app_id, Rails.application.secrets.google_app_secret,
#     {
#       :scope => "email, profile, https://www.googleapis.com/auth/drive.readonly",
#       :prompt => "select_account consent"
#     }
# end