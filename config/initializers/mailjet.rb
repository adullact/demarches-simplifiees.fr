ActiveSupport.on_load(:action_mailer) do
  require 'mailjet'

  Mailjet.configure do |config|
    config.api_key = ENV['MAILJET_API_KEY']
    config.secret_key = ENV['MAILJET_SECRET_KEY']
    config.default_from = CONTACT_EMAIL
  end
end
