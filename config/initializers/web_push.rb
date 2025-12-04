# Web Push VAPID configuration
# Generate keys with: bundle exec rails runner "puts WebPush.generate_key.to_hash"

Rails.application.config.after_initialize do
  if ENV["VAPID_PUBLIC_KEY"].present? && ENV["VAPID_PRIVATE_KEY"].present?
    WebPush.configure do |config|
      config.vapid_public_key = ENV["VAPID_PUBLIC_KEY"]
      config.vapid_private_key = ENV["VAPID_PRIVATE_KEY"]
      config.vapid_subject = "mailto:#{ENV.fetch('VAPID_SUBJECT', 'contact@pingsafe.app')}"
    end
  else
    Rails.logger.warn "VAPID keys not configured. Web Push notifications will not work."
  end
end
